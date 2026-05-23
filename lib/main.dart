import 'dart:ui';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const EstateFlowApp());
}

class EstateFlowApp extends StatelessWidget {
  const EstateFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EstateFlow CRM',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          surface: AppColors.canvas,
        ),
      ),
      home: const CrmShell(),
    );
  }
}

class AppColors {
  static const canvas = Color(0xFFF4F5EF);
  static const panel = Color(0xFFFDFDF9);
  static const panelSoft = Color(0xFFF0F8EE);
  static const mint = Color(0xFFDDFBE9);
  static const mintStrong = Color(0xFFCFF3DD);
  static const green = Color(0xFF008E15);
  static const ink = Color(0xFF050505);
  static const muted = Color(0xFF6F716E);
  static const line = Color(0xFFE1E4DC);
}

class AppFonts {
  static const cabinet = 'CabinetGrotesk';
}

class CrmShell extends StatefulWidget {
  const CrmShell({super.key});

  @override
  State<CrmShell> createState() => _CrmShellState();
}

class _CrmShellState extends State<CrmShell> {
  int _selectedIndex = 0;
  late List<PropertyListing> _properties = List.of(_initialProperties);

  static const _initialProperties = [
    PropertyListing(
      id: 'avelengo-rental',
      title: 'Entire rental unit in Avelengo',
      location: '305 Pomona Ave, Coronado, CA. 92118',
      price: r'$2,500,000',
      oldPrice: r'$2,550,000',
      status: 'Sale',
      image:
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1000&q=90',
      tagColor: Color(0xFFE46773),
    ),
    PropertyListing(
      id: 'coronado-family-house',
      title: 'Single family house in Coronado',
      location: '305 Pomona Ave, Coronado, CA. 92118',
      price: r'$3,600',
      oldPrice: r'$3,950',
      status: 'Rental',
      image:
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1000&q=90',
      tagColor: Color(0xFF36C878),
    ),
    PropertyListing(
      id: 'skyline-apartment',
      title: 'Skyline Apartment near Expressway',
      location: 'Noida Sector 150, Uttar Pradesh',
      price: r'$920,000',
      oldPrice: r'$960,000',
      status: 'Ready',
      image:
          'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1000&q=90',
      tagColor: AppColors.green,
    ),
  ];

  static const _items = [
    _NavItem('Dashboard', HugeIcons.strokeRoundedHome05),
    _NavItem('Leads', HugeIcons.strokeRoundedUserGroup),
    _NavItem('Properties', HugeIcons.strokeRoundedRealEstate01),
    _NavItem('Follow-ups', HugeIcons.strokeRoundedCalendar03),
    _NavItem('More', HugeIcons.strokeRoundedMenuCircle),
  ];

  Future<void> _openAddProperty() async {
    final property = await Navigator.of(context).push<PropertyListing>(
      MaterialPageRoute<PropertyListing>(
        builder: (_) => const AddPropertyScreen(),
      ),
    );

    if (property == null || !mounted) return;

    setState(() {
      _properties = [property, ..._properties];
      _selectedIndex = 2;
    });
  }

  Future<void> _openEditProperty(PropertyListing property) async {
    final updatedProperty = await Navigator.of(context).push<PropertyListing>(
      MaterialPageRoute<PropertyListing>(
        builder: (_) => AddPropertyScreen(property: property),
      ),
    );

    if (updatedProperty == null || !mounted) return;

    setState(() {
      _properties = _properties
          .map((item) => item.id == updatedProperty.id ? updatedProperty : item)
          .toList();
      _selectedIndex = 2;
    });
  }

  void _deleteProperty(PropertyListing property) {
    setState(() {
      _properties = _properties
          .where((item) => item.id != property.id)
          .toList();
    });
  }

  Future<void> _shareProperty(PropertyListing property) async {
    await SharePlus.instance.share(
      ShareParams(
        title: property.title,
        subject: property.title,
        text:
            '${property.title}\n${property.location}\n${property.price}\nStatus: ${property.status}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onAddProperty: _openAddProperty),
      LeadsScreen(onAddProperty: _openAddProperty),
      PropertiesScreen(
        properties: _properties,
        onAddProperty: _openAddProperty,
        onEditProperty: _openEditProperty,
        onDeleteProperty: _deleteProperty,
        onShareProperty: (property) => _shareProperty(property),
      ),
      FollowUpsScreen(onAddProperty: _openAddProperty),
      MoreScreen(onAddProperty: _openAddProperty),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: screens[_selectedIndex]),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: _BottomNavBar(
                  items: _items,
                  selectedIndex: _selectedIndex,
                  onChanged: (index) => setState(() => _selectedIndex = index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final List<List<dynamic>> icon;
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(33),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          height: 66,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF3F4A49).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(33),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < items.length; index++) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(index),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: selectedIndex == index
                              ? Colors.white
                              : const Color(0xFF6D7775).withValues(alpha: 0.72),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: items[index].icon,
                            size: 22,
                            color: selectedIndex == index
                                ? AppColors.ink
                                : const Color(0xFFDDE2DF),
                            strokeWidth: 1.7,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (index != items.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppScreen extends StatelessWidget {
  const AppScreen({
    required this.title,
    required this.subtitle,
    required this.children,
    this.actionIcon,
    this.onAction,
    this.onAddProperty,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<List<dynamic>>? actionIcon;
  final VoidCallback? onAction;
  final VoidCallback? onAddProperty;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 104),
      children: [
        AppHeader(
          title: title,
          subtitle: subtitle,
          actionIcon: actionIcon,
          onAction: onAction,
          onAddProperty: onAddProperty,
        ),
        const SizedBox(height: 22),
        ...children,
      ],
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.title,
    required this.subtitle,
    this.actionIcon,
    this.onAction,
    this.onAddProperty,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<List<dynamic>>? actionIcon;
  final VoidCallback? onAction;
  final VoidCallback? onAddProperty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.muted,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        if (actionIcon == HugeIcons.strokeRoundedAdd01 && onAction == null)
          _MorphingAddButton(
            key: const ValueKey('quick-create-button'),
            onAddProperty: onAddProperty,
          )
        else
          _CircleIconButton(
            icon: actionIcon ?? HugeIcons.strokeRoundedNotification01,
            onTap: onAction,
          ),
      ],
    );
  }
}

class _MorphingAddButton extends StatefulWidget {
  const _MorphingAddButton({this.onAddProperty, super.key});

  final VoidCallback? onAddProperty;

  @override
  State<_MorphingAddButton> createState() => _MorphingAddButtonState();
}

class _MorphingAddButtonState extends State<_MorphingAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  OverlayEntry? _overlayEntry;
  Rect _buttonRect = Rect.zero;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _closeMenu();
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    _buttonRect = topLeft & renderBox.size;
    setState(() => _isMenuOpen = true);
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_overlayEntry!);
    _controller.forward(from: 0);
  }

  Future<void> _closeMenu() async {
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isMenuOpen = false);
    }
  }

  Future<void> _openAddProperty() async {
    await _closeMenu();
    if (!mounted) return;
    widget.onAddProperty?.call();
  }

  Widget _buildOverlay(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final panelWidth = (screenSize.width - 36).clamp(260.0, 310.0);
    final availableHeight = screenSize.height - _buttonRect.top - 18;
    final panelHeight = availableHeight < 336 ? availableHeight : 336.0;
    final targetRect = Rect.fromLTWH(
      screenSize.width - panelWidth - 18,
      _buttonRect.top,
      panelWidth,
      panelHeight,
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _closeMenu,
            child: Container(color: Colors.transparent),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = Curves.easeOutCubic.transform(_controller.value);
            final rect = Rect.lerp(_buttonRect, targetRect, progress)!;
            final radius = lerpDouble(24, 30, progress)!;
            final contentOpacity = ((progress - 0.52) / 0.48).clamp(0.0, 1.0);

            return Positioned.fromRect(
              rect: rect,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8 * progress,
                      sigmaY: 8 * progress,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.panel.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.72),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.16 * progress,
                            ),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: progress < 0.44
                          ? Center(
                              child: Transform.rotate(
                                angle: progress * 0.7,
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedAdd01,
                                  size: 25,
                                  color: AppColors.ink,
                                  strokeWidth: 1.8,
                                ),
                              ),
                            )
                          : Opacity(
                              opacity: contentOpacity,
                              child: SingleChildScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                child: _QuickCreateMenuContent(
                                  onAddProperty: _openAddProperty,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isMenuOpen ? 0 : 1,
      child: _CircleIconButton(
        icon: HugeIcons.strokeRoundedAdd01,
        onTap: _toggleMenu,
      ),
    );
  }
}

class _QuickCreateMenuContent extends StatelessWidget {
  const _QuickCreateMenuContent({required this.onAddProperty});

  final VoidCallback onAddProperty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Create',
            style: TextStyle(
              fontFamily: AppFonts.cabinet,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add CRM records without leaving this screen.',
            style: TextStyle(fontSize: 13.5, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          _QuickCreateMenuItem(
            icon: HugeIcons.strokeRoundedRealEstate01,
            title: 'Add Property',
            subtitle: 'Create inventory listing',
            onTap: onAddProperty,
          ),
          const _QuickCreateMenuItem(
            icon: HugeIcons.strokeRoundedUserAdd01,
            title: 'Add Lead',
            subtitle: 'Capture buyer details',
          ),
          const _QuickCreateMenuItem(
            icon: HugeIcons.strokeRoundedCalendarAdd01,
            title: 'Add Follow-up',
            subtitle: 'Schedule next action',
          ),
          const _QuickCreateMenuItem(
            icon: HugeIcons.strokeRoundedDatabaseImport,
            title: 'Import Lead',
            subtitle: 'Webhook or spreadsheet',
          ),
        ],
      ),
    );
  }
}

class _QuickCreateMenuItem extends StatelessWidget {
  const _QuickCreateMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  size: 20,
                  color: AppColors.ink,
                  strokeWidth: 1.7,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight02,
              size: 18,
              color: AppColors.muted,
              strokeWidth: 1.7,
            ),
          ],
        ),
      ),
    );
  }
}

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({this.property, super.key});

  final PropertyListing? property;

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _priceUnitController;
  late final TextEditingController _cityController;
  late final TextEditingController _localityController;
  late final TextEditingController _addressController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _sizeController;
  late final TextEditingController _floorController;
  late final TextEditingController _bedroomController;
  late final TextEditingController _bathroomController;
  late final TextEditingController _notesController;
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _selectedPhotoPaths = [];
  _PickedPropertyDocument? _brochureDocument;
  _PickedPropertyDocument? _floorPlanDocument;
  int _selectedPropertyTypeIndex = -1;
  int _selectedPurposeIndex = -1;
  int _selectedStatusIndex = -1;
  int _selectedPossessionIndex = -1;
  int _selectedFurnishingIndex = -1;

  static const _propertyTypeOptions = [
    'Apartment',
    'Villa',
    'Plot',
    'Commercial',
  ];
  static const _purposeOptions = ['Sale', 'Rent', 'Lease'];
  static const _statusOptions = ['Available', 'Hold', 'Sold', 'Rented'];
  static const _possessionOptions = ['Ready', 'Under construction', 'Date'];
  static const _furnishingOptions = ['Unfurnished', 'Semi', 'Fully'];

  @override
  void initState() {
    super.initState();
    final property = widget.property;
    _titleController = TextEditingController(text: property?.title ?? '');
    _descriptionController = TextEditingController();
    _priceController = TextEditingController(text: property?.price ?? '');
    _priceUnitController = TextEditingController();
    _cityController = TextEditingController();
    _localityController = TextEditingController();
    _addressController = TextEditingController(text: property?.location ?? '');
    _landmarkController = TextEditingController();
    _sizeController = TextEditingController();
    _floorController = TextEditingController();
    _bedroomController = TextEditingController();
    _bathroomController = TextEditingController();
    _notesController = TextEditingController();
    if (property?.localImagePath != null) {
      _selectedPhotoPaths = [property!.localImagePath!];
    }
    if (property != null) {
      final purpose = property.status == 'Rental' ? 'Rent' : property.status;
      _selectedPurposeIndex = _purposeOptions.indexOf(purpose);
      _selectedStatusIndex = _statusOptions.indexOf(property.status);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _priceUnitController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _sizeController.dispose();
    _floorController.dispose();
    _bedroomController.dispose();
    _bathroomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved locally for this session')),
    );
  }

  void _saveProperty() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property title is required')),
      );
      return;
    }

    final city = _cityController.text.trim();
    final locality = _localityController.text.trim();
    final address = _addressController.text.trim();
    final location = address.isNotEmpty
        ? address
        : [locality, city].where((part) => part.isNotEmpty).join(', ');
    final price = _priceController.text.trim();
    final purpose = _selectedPurposeIndex == -1
        ? 'Sale'
        : _purposeOptions[_selectedPurposeIndex];
    final status = purpose == 'Rent' ? 'Rental' : purpose;

    Navigator.of(context).pop(
      PropertyListing(
        id:
            widget.property?.id ??
            'local-${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        location: location.isEmpty ? 'Location pending' : location,
        price: price.isEmpty ? 'Price pending' : price,
        oldPrice: price.isEmpty ? 'Price pending' : price,
        status: status,
        image:
            widget.property?.image ??
            'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1000&q=90',
        localImagePath: _selectedPhotoPaths.isEmpty
            ? null
            : _selectedPhotoPaths.first,
        tagColor: widget.property?.tagColor ?? AppColors.green,
      ),
    );
  }

  Future<void> _addCameraPhoto() async {
    final photoPaths = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute<List<String>>(
        builder: (_) => const PropertyCameraScreen(),
      ),
    );
    if (photoPaths == null || photoPaths.isEmpty || !mounted) return;

    setState(
      () => _selectedPhotoPaths = [..._selectedPhotoPaths, ...photoPaths],
    );
  }

  Future<void> _addGalleryPhotos() async {
    try {
      final images = await _imagePicker.pickMultiImage(imageQuality: 88);
      if (images.isEmpty || !mounted) return;
      setState(
        () => _selectedPhotoPaths = [
          ..._selectedPhotoPaths,
          ...images.map((image) => image.path),
        ],
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open gallery')));
    }
  }

  Future<void> _pickDocument(_PropertyDocumentKind kind) async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty || !mounted) return;

      final file = result.files.single;
      if (file.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read selected document')),
        );
        return;
      }

      final document = _PickedPropertyDocument(
        name: file.name,
        path: file.path!,
        size: file.size,
      );
      setState(() {
        if (kind == _PropertyDocumentKind.brochure) {
          _brochureDocument = document;
        } else {
          _floorPlanDocument = document;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open document picker')),
      );
    }
  }

  void _clearDocument(_PropertyDocumentKind kind) {
    setState(() {
      if (kind == _PropertyDocumentKind.brochure) {
        _brochureDocument = null;
      } else {
        _floorPlanDocument = null;
      }
    });
  }

  void _setCoverPhoto(String path) {
    setState(() {
      _selectedPhotoPaths = [
        path,
        ..._selectedPhotoPaths.where((photoPath) => photoPath != path),
      ];
    });
    Navigator.maybePop(context);
  }

  void _removePhoto(String path) {
    setState(() {
      _selectedPhotoPaths = _selectedPhotoPaths
          .where((photoPath) => photoPath != path)
          .toList();
    });
    Navigator.maybePop(context);
  }

  void _clearPhotos() {
    setState(() => _selectedPhotoPaths = []);
    Navigator.maybePop(context);
  }

  void _openPhotoManager() {
    if (_selectedPhotoPaths.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PhotoManagerSheet(
        photoPaths: _selectedPhotoPaths,
        onSetCover: _setCoverPhoto,
        onRemove: _removePhoto,
        onClearAll: _clearPhotos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 112),
                children: [
                  const _AddPropertyHeader(),
                  const SizedBox(height: 24),
                  _AddPropertySection(
                    title: 'Basic Details',
                    icon: HugeIcons.strokeRoundedRealEstate01,
                    children: [
                      _PropertyTextInput(
                        label: 'Property title',
                        hint: 'e.g. Modern Simple House',
                        controller: _titleController,
                      ),
                      const SizedBox(height: 10),
                      _PropertyChoiceGroup(
                        label: 'Property type',
                        options: _propertyTypeOptions,
                        selectedIndex: _selectedPropertyTypeIndex,
                        onChanged: (index) =>
                            setState(() => _selectedPropertyTypeIndex = index),
                      ),
                      const SizedBox(height: 10),
                      _PropertyChoiceGroup(
                        label: 'Purpose',
                        options: _purposeOptions,
                        selectedIndex: _selectedPurposeIndex,
                        onChanged: (index) =>
                            setState(() => _selectedPurposeIndex = index),
                      ),
                      const SizedBox(height: 10),
                      _PropertyTextInput(
                        label: 'Short description',
                        hint: 'Add a short buyer-facing description',
                        controller: _descriptionController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AddPropertySection(
                    title: 'Price & Availability',
                    icon: HugeIcons.strokeRoundedDollarCircle,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _PropertyTextInput(
                              label: 'Price',
                              hint: 'e.g. 1.42 Cr',
                              controller: _priceController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PropertyTextInput(
                              label: 'Price unit',
                              hint: 'e.g. Total',
                              controller: _priceUnitController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _PropertyChoiceGroup(
                        label: 'Status',
                        options: _statusOptions,
                        selectedIndex: _selectedStatusIndex,
                        onChanged: (index) =>
                            setState(() => _selectedStatusIndex = index),
                      ),
                      const SizedBox(height: 10),
                      _PropertyChoiceGroup(
                        label: 'Possession',
                        options: _possessionOptions,
                        selectedIndex: _selectedPossessionIndex,
                        onChanged: (index) =>
                            setState(() => _selectedPossessionIndex = index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AddPropertySection(
                    title: 'Location',
                    icon: HugeIcons.strokeRoundedLocation01,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _PropertyTextInput(
                              label: 'City',
                              hint: 'e.g. Gurgaon',
                              controller: _cityController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PropertyTextInput(
                              label: 'Locality',
                              hint: 'e.g. Golf Course Road',
                              controller: _localityController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _PropertyTextInput(
                        label: 'Full address',
                        hint: 'Street, tower, sector or complete address',
                        controller: _addressController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      _PropertyTextInput(
                        label: 'Landmark',
                        hint: 'Nearby landmark',
                        controller: _landmarkController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AddPropertySection(
                    title: 'Features',
                    icon: HugeIcons.strokeRoundedEntranceStairs,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _PropertyTextInput(
                              label: 'Size',
                              hint: 'e.g. 2400 sqft',
                              controller: _sizeController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PropertyTextInput(
                              label: 'Floor',
                              hint: 'e.g. 2',
                              controller: _floorController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _PropertyTextInput(
                              label: 'Bedrooms',
                              hint: 'e.g. 4',
                              controller: _bedroomController,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PropertyTextInput(
                              label: 'Bathrooms',
                              hint: 'e.g. 3',
                              controller: _bathroomController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _PropertyChoiceGroup(
                        label: 'Furnishing',
                        options: _furnishingOptions,
                        selectedIndex: _selectedFurnishingIndex,
                        onChanged: (index) =>
                            setState(() => _selectedFurnishingIndex = index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AddPropertySection(
                    title: 'Photos',
                    icon: HugeIcons.strokeRoundedCameraAdd01,
                    children: [
                      _PhotoUploadGrid(
                        photoPaths: _selectedPhotoPaths,
                        onCameraTap: _addCameraPhoto,
                        onGalleryTap: _addGalleryPhotos,
                        onManageTap: _openPhotoManager,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _AddPropertySection(
                    title: 'Documents & Notes',
                    icon: HugeIcons.strokeRoundedFileAdd,
                    children: [
                      _DocumentUploadRow(
                        brochure: _brochureDocument,
                        floorPlan: _floorPlanDocument,
                        onPickBrochure: () =>
                            _pickDocument(_PropertyDocumentKind.brochure),
                        onPickFloorPlan: () =>
                            _pickDocument(_PropertyDocumentKind.floorPlan),
                        onClearBrochure: () =>
                            _clearDocument(_PropertyDocumentKind.brochure),
                        onClearFloorPlan: () =>
                            _clearDocument(_PropertyDocumentKind.floorPlan),
                      ),
                      const SizedBox(height: 10),
                      _PropertyTextInput(
                        label: 'Internal notes',
                        hint: 'Private team notes',
                        controller: _notesController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 12,
              child: _AddPropertyActions(
                onSaveDraft: _saveDraft,
                onSaveProperty: _saveProperty,
                saveLabel: widget.property == null
                    ? 'Save Property'
                    : 'Update Property',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPropertyHeader extends StatelessWidget {
  const _AddPropertyHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: HugeIcons.strokeRoundedArrowLeft02,
          onTap: () => Navigator.maybePop(context),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Add Property',
              style: TextStyle(
                fontFamily: AppFonts.cabinet,
                fontSize: 29,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -1.2,
              ),
            ),
          ),
        ),
        const _CircleIconButton(icon: HugeIcons.strokeRoundedMoreVertical),
      ],
    );
  }
}

class _AddPropertySection extends StatelessWidget {
  const _AddPropertySection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final List<List<dynamic>> icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SoftIcon(icon: icon, size: 42, iconSize: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _PropertyTextInput extends StatelessWidget {
  const _PropertyTextInput({
    required this.label,
    required this.hint,
    this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              letterSpacing: -0.25,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
                letterSpacing: -0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyChoiceGroup extends StatelessWidget {
  const _PropertyChoiceGroup({
    required this.label,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  });

  final String label;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < options.length; index++) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged?.call(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: index == selectedIndex
                          ? Colors.black
                          : AppColors.panel.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: index == selectedIndex
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    child: Text(
                      options[index],
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: index == selectedIndex
                            ? Colors.white
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ),
                if (index != options.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoUploadGrid extends StatelessWidget {
  const _PhotoUploadGrid({
    required this.photoPaths,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onManageTap,
  });

  final List<String> photoPaths;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onManageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: photoPaths.isEmpty ? onGalleryTap : onManageTap,
          child: Container(
            height: 148,
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: photoPaths.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCameraAdd01,
                            size: 32,
                            color: AppColors.ink,
                            strokeWidth: 1.7,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Add cover photo',
                            style: TextStyle(
                              fontFamily: AppFonts.cabinet,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Take photo or choose from gallery',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(photoPaths.first), fit: BoxFit.cover),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.42),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 12,
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Cover photo',
                                  style: TextStyle(
                                    fontFamily: AppFonts.cabinet,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${photoPaths.length} photo${photoPaths.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (photoPaths.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoPaths.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 62,
                  height: 58,
                  child: Image.file(File(photoPaths[index]), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SmallMediaTile(
                icon: HugeIcons.strokeRoundedCamera01,
                label: 'Camera',
                onTap: onCameraTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SmallMediaTile(
                icon: HugeIcons.strokeRoundedImage01,
                label: 'Gallery',
                onTap: onGalleryTap,
              ),
            ),
            if (photoPaths.isNotEmpty) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _SmallMediaTile(
                  icon: HugeIcons.strokeRoundedMoreHorizontal,
                  label: 'Manage',
                  onTap: onManageTap,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SmallMediaTile extends StatelessWidget {
  const _SmallMediaTile({required this.icon, required this.label, this.onTap});

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: AppColors.panel.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              size: 22,
              color: AppColors.ink,
              strokeWidth: 1.7,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PropertyDocumentKind { brochure, floorPlan }

class _PickedPropertyDocument {
  const _PickedPropertyDocument({
    required this.name,
    required this.path,
    required this.size,
  });

  final String name;
  final String path;
  final int size;

  String get formattedSize {
    if (size <= 0) return 'Selected';
    final kilobytes = size / 1024;
    if (kilobytes < 1024) return '${kilobytes.toStringAsFixed(0)} KB';
    return '${(kilobytes / 1024).toStringAsFixed(1)} MB';
  }
}

class _PhotoManagerSheet extends StatelessWidget {
  const _PhotoManagerSheet({
    required this.photoPaths,
    required this.onSetCover,
    required this.onRemove,
    required this.onClearAll,
  });

  final List<String> photoPaths;
  final ValueChanged<String> onSetCover;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: _GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Manage Photos',
                    style: TextStyle(
                      fontFamily: AppFonts.cabinet,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.maybePop(context),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      size: 24,
                      color: AppColors.muted,
                      strokeWidth: 1.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap Set cover to make a photo the listing preview.',
                style: TextStyle(fontSize: 13.5, color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: photoPaths.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final path = photoPaths[index];
                    final isCover = index == 0;
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            width: 68,
                            height: 62,
                            child: Image.file(File(path), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCover
                                    ? 'Cover photo'
                                    : 'Property photo ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                  letterSpacing: -0.25,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (!isCover)
                                    _PhotoSheetAction(
                                      label: 'Set cover',
                                      onTap: () => onSetCover(path),
                                    ),
                                  if (!isCover) const SizedBox(width: 8),
                                  _PhotoSheetAction(
                                    label: 'Remove',
                                    isDestructive: true,
                                    onTap: () => onRemove(path),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClearAll,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7EA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Clear all photos',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC62836),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoSheetAction extends StatelessWidget {
  const _PhotoSheetAction({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFE7EA) : AppColors.mint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: isDestructive ? const Color(0xFFC62836) : AppColors.green,
          ),
        ),
      ),
    );
  }
}

class PropertyCameraScreen extends StatefulWidget {
  const PropertyCameraScreen({super.key});

  @override
  State<PropertyCameraScreen> createState() => _PropertyCameraScreenState();
}

class _PropertyCameraScreenState extends State<PropertyCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  final math.Random _deckRandom = math.Random();
  List<_CapturedCameraPhoto> _capturedPhotos = [];
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isPermissionPermanentlyDenied = false;
  double _selectedFrameAspectRatio = 3 / 4;
  bool _useFullscreenFrame = false;
  String? _error;

  static const _aspectRatioOptions = [
    _CameraAspectOption(label: '1:1', value: 1),
    _CameraAspectOption(label: '3:4', value: 3 / 4),
    _CameraAspectOption(label: '4:3', value: 4 / 3),
    _CameraAspectOption(label: '16:9', value: 16 / 9),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera([CameraDescription? selectedCamera]) async {
    setState(() {
      _isInitializing = true;
      _error = null;
      _isPermissionPermanentlyDenied = false;
    });

    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _isPermissionPermanentlyDenied = permission.isPermanentlyDenied;
          _error = permission.isPermanentlyDenied
              ? 'Camera permission is blocked'
              : 'Camera permission is required';
        });
        return;
      }

      final cameras = _cameras.isEmpty ? await availableCameras() : _cameras;
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _cameras = cameras;
          _isInitializing = false;
          _error = 'No camera found on this device';
        });
        return;
      }

      final camera = selectedCamera ?? cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller?.dispose();
      _controller = controller;
      await controller.initialize();

      if (!mounted) return;
      setState(() {
        _cameras = cameras;
        _isInitializing = false;
      });
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _error = error.description ?? 'Could not initialize camera';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _error = 'Could not initialize camera';
      });
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final targetAspectRatio = _useFullscreenFrame
          ? null
          : _selectedFrameAspectRatio;
      final image = await controller.takePicture();
      final imagePath = await _processCapturedImage(
        path: image.path,
        shouldFlip:
            controller.description.lensDirection == CameraLensDirection.front,
        targetAspectRatio: targetAspectRatio,
      );
      final aspectRatio = await _readImageAspectRatio(imagePath);
      if (!mounted) return;
      setState(
        () => _capturedPhotos = [
          ..._capturedPhotos,
          _CapturedCameraPhoto.random(
            path: imagePath,
            aspectRatio: aspectRatio,
            random: _deckRandom,
          ),
        ],
      );
    } on CameraException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.description ?? 'Could not capture photo')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not process photo')));
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<String> _processCapturedImage({
    required String path,
    required bool shouldFlip,
    required double? targetAspectRatio,
  }) async {
    if (!shouldFlip && targetAspectRatio == null) return path;

    final file = File(path);
    final bytes = await file.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return path;

    final fixedImage = shouldFlip
        ? img.flipHorizontal(decodedImage)
        : decodedImage;
    final croppedImage = targetAspectRatio == null
        ? fixedImage
        : _centerCropImage(fixedImage, targetAspectRatio);

    await file.writeAsBytes(
      img.encodeJpg(croppedImage, quality: 92),
      flush: true,
    );
    return path;
  }

  img.Image _centerCropImage(img.Image source, double targetAspectRatio) {
    final sourceAspectRatio = source.width / source.height;
    if ((sourceAspectRatio - targetAspectRatio).abs() < 0.01) return source;

    var cropWidth = source.width;
    var cropHeight = source.height;

    if (sourceAspectRatio > targetAspectRatio) {
      cropWidth = (source.height * targetAspectRatio).round();
    } else {
      cropHeight = (source.width / targetAspectRatio).round();
    }

    cropWidth = cropWidth.clamp(1, source.width);
    cropHeight = cropHeight.clamp(1, source.height);

    return img.copyCrop(
      source,
      x: ((source.width - cropWidth) / 2).round(),
      y: ((source.height - cropHeight) / 2).round(),
      width: cropWidth,
      height: cropHeight,
    );
  }

  Future<double> _readImageAspectRatio(String path) async {
    final bytes = await File(path).readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null || decodedImage.height == 0) return 1;
    return decodedImage.width / decodedImage.height;
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final currentCamera = _controller?.description;
    final currentIndex = _cameras.indexWhere(
      (camera) => camera.name == currentCamera?.name,
    );
    final nextCamera = _cameras[(currentIndex + 1) % _cameras.length];
    await _initializeCamera(nextCamera);
  }

  void _removeCapture(String path) {
    setState(() {
      _capturedPhotos = _capturedPhotos
          .where((photo) => photo.path != path)
          .toList();
    });
    if (_capturedPhotos.isEmpty) {
      Navigator.maybePop(context);
    }
  }

  Future<void> _openCapturedPhotoReview() async {
    if (_capturedPhotos.isEmpty) return;

    final updatedPhotos = await Navigator.of(context)
        .push<List<_CapturedCameraPhoto>>(
          PageRouteBuilder<List<_CapturedCameraPhoto>>(
            opaque: false,
            barrierColor: Colors.black.withValues(alpha: 0.42),
            pageBuilder: (context, animation, secondaryAnimation) =>
                _CapturedPhotoGalleryScreen(photos: _capturedPhotos),
            transitionDuration: const Duration(milliseconds: 260),
            reverseTransitionDuration: const Duration(milliseconds: 220),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(curvedAnimation);
                  return FadeTransition(
                    opacity: curvedAnimation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
          ),
        );

    if (updatedPhotos == null || !mounted) return;
    setState(() => _capturedPhotos = updatedPhotos);
  }

  void _finishCapture() {
    Navigator.of(
      context,
    ).pop(_capturedPhotos.map((photo) => photo.path).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildCameraBody()),
            Positioned(
              left: 16,
              right: 16,
              top: 14,
              child: _CameraTopBar(
                count: _capturedPhotos.length,
                onClose: () => Navigator.maybePop(context),
                onDone: _capturedPhotos.isEmpty ? null : _finishCapture,
              ),
            ),
            if (_controller?.value.isInitialized == true && _error == null)
              Positioned(
                left: 16,
                right: 16,
                top: 80,
                child: _CameraAspectRatioBar(
                  options: _aspectRatioOptions,
                  selectedValue: _selectedFrameAspectRatio,
                  useFullscreenFrame: _useFullscreenFrame,
                  onChanged: (value) => setState(() {
                    _selectedFrameAspectRatio = value;
                    _useFullscreenFrame = false;
                  }),
                  onFullscreenTap: () =>
                      setState(() => _useFullscreenFrame = true),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _CameraBottomBar(
                capturedPhotos: _capturedPhotos,
                isCapturing: _isCapturing,
                canSwitchCamera: _cameras.length > 1,
                onCapture: _capturePhoto,
                onSwitchCamera: _switchCamera,
                onRemoveCapture: _removeCapture,
                onReviewCaptures: _openCapturedPhotoReview,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraBody() {
    final controller = _controller;
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null ||
        controller == null ||
        !controller.value.isInitialized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedCameraOff01,
                size: 42,
                color: Colors.white,
                strokeWidth: 1.7,
              ),
              const SizedBox(height: 14),
              Text(
                _error ?? 'Camera is not available',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Check permissions or try again from the property form.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isPermissionPermanentlyDenied
                    ? openAppSettings
                    : () => _initializeCamera(),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isPermissionPermanentlyDenied
                        ? 'Open Settings'
                        : 'Allow Camera',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final frameAspectRatio = _useFullscreenFrame
            ? constraints.maxWidth / constraints.maxHeight
            : _selectedFrameAspectRatio;

        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_useFullscreenFrame ? 0 : 28),
            child: AspectRatio(
              aspectRatio: frameAspectRatio,
              child: _CroppedCameraPreview(controller: controller),
            ),
          ),
        );
      },
    );
  }
}

class _CameraAspectOption {
  const _CameraAspectOption({required this.label, required this.value});

  final String label;
  final double value;
}

class _CroppedCameraPreview extends StatelessWidget {
  const _CroppedCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    final previewWidth = previewSize?.height ?? 1080;
    final previewHeight = previewSize?.width ?? 1920;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewWidth,
            height: previewHeight,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

class _CameraAspectRatioBar extends StatelessWidget {
  const _CameraAspectRatioBar({
    required this.options,
    required this.selectedValue,
    required this.useFullscreenFrame,
    required this.onChanged,
    required this.onFullscreenTap,
  });

  final List<_CameraAspectOption> options;
  final double selectedValue;
  final bool useFullscreenFrame;
  final ValueChanged<double> onChanged;
  final VoidCallback onFullscreenTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onFullscreenTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: useFullscreenFrame ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Full',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: useFullscreenFrame ? AppColors.ink : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            for (final option in options) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(option.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: option.value == selectedValue
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: option.value == selectedValue
                          ? AppColors.ink
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              if (option != options.last) const SizedBox(width: 2),
            ],
          ],
        ),
      ),
    );
  }
}

class _CameraTopBar extends StatelessWidget {
  const _CameraTopBar({
    required this.count,
    required this.onClose,
    required this.onDone,
  });

  final int count;
  final VoidCallback onClose;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CameraCircleButton(
          icon: HugeIcons.strokeRoundedCancel01,
          onTap: onClose,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            alignment: Alignment.center,
            child: Text(
              count == 0
                  ? 'Capture property photos'
                  : '$count photo${count == 1 ? '' : 's'} captured',
              style: const TextStyle(
                fontFamily: AppFonts.cabinet,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.35,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onDone,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: onDone == null ? Colors.white24 : AppColors.mint,
              borderRadius: BorderRadius.circular(26),
            ),
            alignment: Alignment.center,
            child: Text(
              'Done',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: onDone == null ? Colors.white60 : AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CapturedCameraPhoto {
  const _CapturedCameraPhoto({
    required this.path,
    required this.aspectRatio,
    required this.rotation,
    required this.offset,
    required this.scale,
  });

  factory _CapturedCameraPhoto.random({
    required String path,
    required double aspectRatio,
    required math.Random random,
  }) {
    double randomBetween(double min, double max) {
      return min + (random.nextDouble() * (max - min));
    }

    return _CapturedCameraPhoto(
      path: path,
      aspectRatio: aspectRatio,
      rotation: randomBetween(-0.18, 0.18),
      offset: Offset(randomBetween(-7, 7), randomBetween(-4, 5)),
      scale: randomBetween(0.96, 1.03),
    );
  }

  final String path;
  final double aspectRatio;
  final double rotation;
  final Offset offset;
  final double scale;
}

class _CameraBottomBar extends StatelessWidget {
  const _CameraBottomBar({
    required this.capturedPhotos,
    required this.isCapturing,
    required this.canSwitchCamera,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.onRemoveCapture,
    required this.onReviewCaptures,
  });

  final List<_CapturedCameraPhoto> capturedPhotos;
  final bool isCapturing;
  final bool canSwitchCamera;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final ValueChanged<String> onRemoveCapture;
  final VoidCallback onReviewCaptures;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _CameraCircleButton(
          icon: HugeIcons.strokeRoundedRefresh,
          onTap: canSwitchCamera ? onSwitchCamera : null,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isCapturing ? null : onCapture,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: isCapturing ? Colors.white54 : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mint, width: 7),
            ),
            child: Center(
              child: Container(
                width: isCapturing ? 24 : 58,
                height: isCapturing ? 24 : 58,
                decoration: BoxDecoration(
                  color: isCapturing ? AppColors.ink : Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        _CapturedPhotoDeck(
          photos: capturedPhotos,
          onTap: capturedPhotos.isEmpty ? null : onReviewCaptures,
          onRemoveLatest: capturedPhotos.isEmpty
              ? null
              : () => onRemoveCapture(capturedPhotos.last.path),
        ),
      ],
    );
  }
}

class _CapturedPhotoDeck extends StatelessWidget {
  const _CapturedPhotoDeck({
    required this.photos,
    this.onTap,
    this.onRemoveLatest,
  });

  final List<_CapturedCameraPhoto> photos;
  final VoidCallback? onTap;
  final VoidCallback? onRemoveLatest;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const _CameraCircleButton(icon: HugeIcons.strokeRoundedImage01);
    }

    final visiblePhotos = photos.length <= 3
        ? photos
        : photos.sublist(photos.length - 3);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onRemoveLatest,
      child: SizedBox(
        width: 72,
        height: 82,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: Tween<double>(begin: 0.72, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Stack(
            key: ValueKey(photos.length),
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              for (var index = 0; index < visiblePhotos.length; index++)
                _CapturedDeckCard(
                  photo: visiblePhotos[index],
                  stackIndex: index,
                  total: visiblePhotos.length,
                ),
              Positioned(
                right: -2,
                bottom: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${photos.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapturedDeckCard extends StatelessWidget {
  const _CapturedDeckCard({
    required this.photo,
    required this.stackIndex,
    required this.total,
  });

  final _CapturedCameraPhoto photo;
  final int stackIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isTopCard = stackIndex == total - 1;
    final baseOffset = isTopCard
        ? Offset.zero
        : Offset((stackIndex - total + 1) * 4.0, stackIndex * 2.0);
    final offset = baseOffset + photo.offset;

    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: photo.rotation,
        child: Container(
          width: 56 * photo.scale,
          height: 64 * photo.scale,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white, width: 2.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.file(File(photo.path), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _CapturedPhotoGalleryScreen extends StatefulWidget {
  const _CapturedPhotoGalleryScreen({required this.photos});

  final List<_CapturedCameraPhoto> photos;

  @override
  State<_CapturedPhotoGalleryScreen> createState() =>
      _CapturedPhotoGalleryScreenState();
}

class _CapturedPhotoGalleryScreenState
    extends State<_CapturedPhotoGalleryScreen> {
  late List<_CapturedCameraPhoto> _photos = List.of(widget.photos);

  void _removePhoto(_CapturedCameraPhoto photo) {
    setState(() {
      _photos = _photos.where((item) => item.path != photo.path).toList();
    });
    if (_photos.isEmpty) {
      Navigator.of(context).pop(_photos);
    }
  }

  void _close() {
    Navigator.of(context).pop(_photos);
  }

  void _openFullView(_CapturedCameraPhoto photo) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _CapturedPhotoFullScreen(photo: photo),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(opacity: curvedAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panelMaxHeight = MediaQuery.sizeOf(context).height * 0.76;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _close,
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Container(
                  constraints: BoxConstraints(maxHeight: panelMaxHeight),
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101211),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_photos.length} captured photo${_photos.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontFamily: AppFonts.cabinet,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _close,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                size: 24,
                                color: Colors.white70,
                                strokeWidth: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hold a photo for full view. Tap X to remove it.',
                        style: TextStyle(fontSize: 13.5, color: Colors.white60),
                      ),
                      const SizedBox(height: 14),
                      Flexible(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemCount: _photos.length,
                          itemBuilder: (context, index) {
                            final photo = _photos[index];
                            return _CapturedGalleryTile(
                              photo: photo,
                              index: index,
                              onRemove: () => _removePhoto(photo),
                              onFullView: () => _openFullView(photo),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapturedGalleryTile extends StatelessWidget {
  const _CapturedGalleryTile({
    required this.photo,
    required this.index,
    required this.onRemove,
    required this.onFullView,
  });

  final _CapturedCameraPhoto photo;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onFullView;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onFullView,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Hero(
                tag: 'captured-photo-${photo.path}',
                child: Image.file(File(photo.path), fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.34),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.46),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '#${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 16,
                    color: AppColors.ink,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapturedPhotoFullScreen extends StatelessWidget {
  const _CapturedPhotoFullScreen({required this.photo});

  final _CapturedCameraPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.maybePop(context),
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.75,
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: 'captured-photo-${photo.path}',
                    child: Image.file(File(photo.path)),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 18,
              top: 18,
              child: SafeArea(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCancel01,
                      size: 22,
                      color: AppColors.ink,
                      strokeWidth: 1.8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraCircleButton extends StatelessWidget {
  const _CameraCircleButton({required this.icon, this.onTap});

  final List<List<dynamic>> icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.42),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Center(
          child: HugeIcon(
            icon: icon,
            size: 23,
            color: onTap == null ? Colors.white38 : Colors.white,
            strokeWidth: 1.7,
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadRow extends StatelessWidget {
  const _DocumentUploadRow({
    required this.brochure,
    required this.floorPlan,
    required this.onPickBrochure,
    required this.onPickFloorPlan,
    required this.onClearBrochure,
    required this.onClearFloorPlan,
  });

  final _PickedPropertyDocument? brochure;
  final _PickedPropertyDocument? floorPlan;
  final VoidCallback onPickBrochure;
  final VoidCallback onPickFloorPlan;
  final VoidCallback onClearBrochure;
  final VoidCallback onClearFloorPlan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DocumentUploadTile(
            icon: HugeIcons.strokeRoundedFileAdd,
            label: 'Brochure',
            document: brochure,
            onTap: onPickBrochure,
            onClear: onClearBrochure,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DocumentUploadTile(
            icon: HugeIcons.strokeRoundedDocumentAttachment,
            label: 'Floor Plan',
            document: floorPlan,
            onTap: onPickFloorPlan,
            onClear: onClearFloorPlan,
          ),
        ),
      ],
    );
  }
}

class _DocumentUploadTile extends StatelessWidget {
  const _DocumentUploadTile({
    required this.icon,
    required this.label,
    required this.document,
    required this.onTap,
    required this.onClear,
  });

  final List<List<dynamic>> icon;
  final String label;
  final _PickedPropertyDocument? document;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final selectedDocument = document;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selectedDocument == null
              ? AppColors.panel.withValues(alpha: 0.78)
              : AppColors.mint.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedDocument == null
                ? Colors.white.withValues(alpha: 0.9)
                : AppColors.green.withValues(alpha: 0.22),
            width: 1.1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: icon,
                  size: 23,
                  color: AppColors.ink,
                  strokeWidth: 1.7,
                ),
                const SizedBox(height: 8),
                Text(
                  selectedDocument?.name ?? label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  selectedDocument?.formattedSize ?? 'Pick any format',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            if (selectedDocument != null)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClear,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: 14,
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddPropertyActions extends StatelessWidget {
  const _AddPropertyActions({
    required this.onSaveDraft,
    required this.onSaveProperty,
    required this.saveLabel,
  });

  final VoidCallback onSaveDraft;
  final VoidCallback onSaveProperty;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSaveDraft,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Save Draft',
                style: TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSaveProperty,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: Text(
                saveLabel,
                style: TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({this.onAddProperty, super.key});

  final VoidCallback? onAddProperty;

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'EstateFlow',
      subtitle: 'Today\'s real estate command center',
      onAddProperty: onAddProperty,
      children: [
        const _HeroMetricCard(),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _MiniMetricCard(
                label: 'New leads',
                value: '18',
                icon: HugeIcons.strokeRoundedUserAdd01,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MiniMetricCard(
                label: 'Calls due',
                value: '42',
                icon: HugeIcons.strokeRoundedCall02,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _MiniMetricCard(
                label: 'Hot leads',
                value: '7',
                icon: HugeIcons.strokeRoundedFire,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MiniMetricCard(
                label: 'Inventory',
                value: '64',
                icon: HugeIcons.strokeRoundedBuilding03,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionHeader(title: 'Recent activity', action: 'View all'),
        const SizedBox(height: 10),
        const _ActivityTile(
          icon: HugeIcons.strokeRoundedMessage01,
          title: 'Property details shared',
          meta: 'Rahul Sharma · 12 min ago',
        ),
        const _ActivityTile(
          icon: HugeIcons.strokeRoundedCalendarCheckIn01,
          title: 'Site visit scheduled',
          meta: 'DLF Phase 3 · 2:30 pm',
        ),
        const _ActivityTile(
          icon: HugeIcons.strokeRoundedUserCheck01,
          title: 'New hot lead assigned',
          meta: 'Priya Mehta · Instagram',
        ),
      ],
    );
  }
}

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({this.onAddProperty, super.key});

  final VoidCallback? onAddProperty;

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Leads',
      subtitle: 'Qualify buyers and track every touchpoint',
      actionIcon: HugeIcons.strokeRoundedAdd01,
      onAddProperty: onAddProperty,
      children: [
        const _SearchFilterBar(hint: 'Search leads, phone or source'),
        const SizedBox(height: 14),
        const _SegmentPills(labels: ['All', 'Hot', 'New', 'Visit', 'Won']),
        const SizedBox(height: 14),
        _LeadCard(
          name: 'Rahul Sharma',
          source: '36 Acre',
          budget: '₹75L - ₹1.2Cr',
          status: 'Hot',
          color: AppColors.mint,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _LeadCard(
          name: 'Priya Mehta',
          source: 'Instagram',
          budget: '3BHK · Gurgaon',
          status: 'New',
          color: AppColors.panel,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _LeadCard(
          name: 'Aman Verma',
          source: 'MagicBricks',
          budget: 'Plot · South Delhi',
          status: 'Follow-up',
          color: AppColors.panel,
          onTap: () {},
        ),
      ],
    );
  }
}

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({
    required this.properties,
    this.onAddProperty,
    this.onEditProperty,
    this.onDeleteProperty,
    this.onShareProperty,
    super.key,
  });

  final List<PropertyListing> properties;
  final VoidCallback? onAddProperty;
  final ValueChanged<PropertyListing>? onEditProperty;
  final ValueChanged<PropertyListing>? onDeleteProperty;
  final ValueChanged<PropertyListing>? onShareProperty;

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

enum _FocusedPropertyLayout { card, list }

class _PropertiesScreenState extends State<PropertiesScreen> {
  bool _isCardView = true;
  PropertyListing? _focusedProperty;
  _FocusedPropertyLayout _focusedLayout = _FocusedPropertyLayout.card;
  Rect? _focusedSourceRect;
  final Map<String, GlobalKey> _propertyKeys = {};

  GlobalKey _propertyKey(PropertyListing property) {
    return _propertyKeys.putIfAbsent(property.id, GlobalKey.new);
  }

  void _openDetails(PropertyListing property) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PropertyDetailsScreen(property: property),
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(opacity: curvedAnimation, child: child);
        },
      ),
    );
  }

  void _focusProperty(PropertyListing property, _FocusedPropertyLayout layout) {
    final renderObject = _propertyKey(
      property,
    ).currentContext?.findRenderObject();
    final renderBox = renderObject is RenderBox ? renderObject : null;
    final sourceRect = renderBox == null || !renderBox.hasSize
        ? null
        : renderBox.localToGlobal(Offset.zero) & renderBox.size;

    setState(() {
      _focusedProperty = property;
      _focusedLayout = layout;
      _focusedSourceRect = sourceRect;
    });
  }

  void _clearFocusedProperty() {
    setState(() {
      _focusedProperty = null;
      _focusedSourceRect = null;
    });
  }

  void _editFocusedProperty(PropertyListing property) {
    _clearFocusedProperty();
    widget.onEditProperty?.call(property);
  }

  void _shareFocusedProperty(PropertyListing property) {
    _clearFocusedProperty();
    widget.onShareProperty?.call(property);
  }

  Future<void> _confirmDeleteProperty(PropertyListing property) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeletePropertySheet(property: property),
    );
    if (shouldDelete != true || !mounted) return;

    _clearFocusedProperty();
    widget.onDeleteProperty?.call(property);
  }

  @override
  Widget build(BuildContext context) {
    final focusedProperty = _focusedProperty;

    return Stack(
      children: [
        AppScreen(
          title: 'Properties',
          subtitle: 'Inventory, availability and shareable listings',
          actionIcon: HugeIcons.strokeRoundedAdd01,
          onAddProperty: widget.onAddProperty,
          children: [
            const _SearchFilterBar(hint: 'Search location, budget or type'),
            const SizedBox(height: 14),
            _PropertyViewToggle(
              isCardView: _isCardView,
              onChanged: (value) => setState(() => _isCardView = value),
            ),
            const SizedBox(height: 14),
            if (_isCardView) ...[
              for (final property in widget.properties) ...[
                KeyedSubtree(
                  key: _propertyKey(property),
                  child: _PropertyFeedCard(
                    property: property,
                    onTap: () => _openDetails(property),
                    onLongPress: () =>
                        _focusProperty(property, _FocusedPropertyLayout.card),
                  ),
                ),
                if (property != widget.properties.last)
                  const SizedBox(height: 12),
              ],
            ] else ...[
              for (final property in widget.properties) ...[
                KeyedSubtree(
                  key: _propertyKey(property),
                  child: _PropertyListCard(
                    property: property,
                    onTap: () => _openDetails(property),
                    onLongPress: () =>
                        _focusProperty(property, _FocusedPropertyLayout.list),
                  ),
                ),
                if (property != widget.properties.last)
                  const SizedBox(height: 12),
              ],
            ],
          ],
        ),
        if (focusedProperty != null)
          _FocusedPropertyOverlay(
            property: focusedProperty,
            layout: _focusedLayout,
            sourceRect: _focusedSourceRect,
            onDismiss: _clearFocusedProperty,
            onOpenDetails: () {
              _clearFocusedProperty();
              _openDetails(focusedProperty);
            },
            onShare: () => _shareFocusedProperty(focusedProperty),
            onEdit: () => _editFocusedProperty(focusedProperty),
            onDelete: () => _confirmDeleteProperty(focusedProperty),
          ),
      ],
    );
  }
}

class _FocusedPropertyOverlay extends StatelessWidget {
  const _FocusedPropertyOverlay({
    required this.property,
    required this.layout,
    required this.sourceRect,
    required this.onDismiss,
    required this.onOpenDetails,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
  });

  final PropertyListing property;
  final _FocusedPropertyLayout layout;
  final Rect? sourceRect;
  final VoidCallback onDismiss;
  final VoidCallback onOpenDetails;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final fallbackWidth = math.min(screenSize.width - 36, 430.0);
    final fallbackHeight = layout == _FocusedPropertyLayout.card
        ? 372.0
        : 124.0;
    final startRect =
        sourceRect ??
        Rect.fromCenter(
          center: Offset(screenSize.width / 2, screenSize.height / 2),
          width: fallbackWidth,
          height: fallbackHeight,
        );
    final endRect = _focusedTargetRect(
      screenSize: screenSize,
      sourceRect: startRect,
    );

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.28),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  final rect = Rect.lerp(startRect, endRect, value)!;
                  final actionsOpacity = ((value - 0.62) / 0.38).clamp(
                    0.0,
                    1.0,
                  );

                  return Stack(
                    children: [
                      Positioned.fromRect(
                        rect: rect,
                        child: Transform.scale(
                          scale: lerpDouble(1, 1.02, value)!,
                          child: child,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: rect.bottom + 14,
                        child: IgnorePointer(
                          ignoring: actionsOpacity == 0,
                          child: Opacity(
                            opacity: actionsOpacity,
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1 - actionsOpacity)),
                              child: Center(
                                child: _FocusedPropertyActions(
                                  onShare: onShare,
                                  onEdit: onEdit,
                                  onDelete: onDelete,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: SizedBox.expand(
                    child: layout == _FocusedPropertyLayout.card
                        ? _PropertyFeedCard(
                            property: property,
                            onTap: onOpenDetails,
                            enableHero: false,
                          )
                        : _PropertyListCard(
                            property: property,
                            onTap: onOpenDetails,
                            enableHero: false,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Rect _focusedTargetRect({
    required Size screenSize,
    required Rect sourceRect,
  }) {
    const horizontalMargin = 18.0;
    const topMargin = 24.0;
    const bottomReserved = 214.0;
    final targetWidth = math.min(
      screenSize.width - (horizontalMargin * 2),
      430.0,
    );
    final targetHeight = sourceRect.height;
    final availableHeight = screenSize.height - topMargin - bottomReserved;
    final targetTop =
        topMargin + math.max(0, (availableHeight - targetHeight) / 2);

    return Rect.fromLTWH(
      (screenSize.width - targetWidth) / 2,
      targetTop,
      targetWidth,
      targetHeight,
    );
  }
}

class _FocusedPropertyActions extends StatelessWidget {
  const _FocusedPropertyActions({
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FocusedPropertyActionButton(
            icon: HugeIcons.strokeRoundedShare08,
            label: 'Share',
            onTap: onShare,
          ),
          const SizedBox(width: 8),
          _FocusedPropertyActionButton(
            icon: HugeIcons.strokeRoundedEdit02,
            label: 'Edit',
            onTap: onEdit,
          ),
          const SizedBox(width: 8),
          _FocusedPropertyActionButton(
            icon: HugeIcons.strokeRoundedDelete02,
            label: 'Delete',
            destructive: true,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _FocusedPropertyActionButton extends StatelessWidget {
  const _FocusedPropertyActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final List<List<dynamic>> icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive ? const Color(0xFFB4282D) : AppColors.ink;
    final background = destructive
        ? const Color(0xFFFFE8EA)
        : AppColors.mint.withValues(alpha: 0.82);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 86,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, size: 20, color: foreground, strokeWidth: 1.8),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeletePropertySheet extends StatelessWidget {
  const _DeletePropertySheet({required this.property});

  final PropertyListing property;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: _GlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete property?',
                style: TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This will remove ${property.title} from your local property list.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB4282D),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyListing {
  const PropertyListing({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.oldPrice,
    required this.status,
    required this.image,
    this.localImagePath,
    required this.tagColor,
  });

  final String id;
  final String title;
  final String location;
  final String price;
  final String oldPrice;
  final String status;
  final String image;
  final String? localImagePath;
  final Color tagColor;

  String get heroTag => 'property-image-$id';
}

class _PropertyImage extends StatelessWidget {
  const _PropertyImage({
    required this.property,
    required this.fit,
    this.width,
    this.height,
  });

  final PropertyListing property;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final localImagePath = property.localImagePath;
    if (localImagePath != null) {
      return Image.file(
        File(localImagePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            Container(width: width, height: height, color: AppColors.line),
      );
    }

    return Image.network(
      property.image,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          Container(width: width, height: height, color: AppColors.line),
    );
  }
}

class FollowUpsScreen extends StatelessWidget {
  const FollowUpsScreen({this.onAddProperty, super.key});

  final VoidCallback? onAddProperty;

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Follow-ups',
      subtitle: 'Calls, reminders and WhatsApp nudges due today',
      actionIcon: HugeIcons.strokeRoundedCalendarAdd01,
      onAddProperty: onAddProperty,
      children: const [
        _FollowUpSummaryCard(),
        SizedBox(height: 12),
        _FollowUpTile(
          time: '10:30 am',
          name: 'Rahul Sharma',
          task: 'Send 3BHK Golf Course options',
          method: 'WhatsApp',
        ),
        _FollowUpTile(
          time: '12:00 pm',
          name: 'Priya Mehta',
          task: 'Confirm Saturday site visit',
          method: 'Call',
        ),
        _FollowUpTile(
          time: '4:15 pm',
          name: 'Aman Verma',
          task: 'Share revised price sheet',
          method: 'Email',
        ),
      ],
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({this.onAddProperty, super.key});

  final VoidCallback? onAddProperty;

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'More',
      subtitle: 'Operations, team and admin settings',
      actionIcon: HugeIcons.strokeRoundedSettings01,
      onAddProperty: onAddProperty,
      children: const [
        _MoreTile(
          icon: HugeIcons.strokeRoundedLocation01,
          title: 'Attendance',
          subtitle: 'Check-ins, field visits and GPS history',
        ),
        _MoreTile(
          icon: HugeIcons.strokeRoundedCalendar03,
          title: 'Site Visits',
          subtitle: 'Upcoming property tours and visit notes',
        ),
        _MoreTile(
          icon: HugeIcons.strokeRoundedInstagram,
          title: 'Social Media',
          subtitle: 'Content calendar and scheduled posts',
        ),
        _MoreTile(
          icon: HugeIcons.strokeRoundedUserGroup,
          title: 'Team',
          subtitle: 'Invite members and manage roles',
        ),
        _MoreTile(
          icon: HugeIcons.strokeRoundedSettings02,
          title: 'Integrations',
          subtitle: 'WhatsApp, storage and future voice agents',
        ),
      ],
    );
  }
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SoftIcon(icon: HugeIcons.strokeRoundedChartUp),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '+18% this week',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            '₹8.64Cr',
            style: TextStyle(
              fontFamily: AppFonts.cabinet,
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -2.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pipeline value across 46 active opportunities',
            style: TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: 0.68,
              backgroundColor: AppColors.line,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SoftIcon(icon: icon, size: 42, iconSize: 20),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.cabinet,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.muted,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.cabinet,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
        ),
        const Spacer(),
        Text(
          action,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.green,
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.meta,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _SoftIcon(icon: icon, size: 44, iconSize: 21),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.muted,
                      letterSpacing: -0.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  const _SearchFilterBar({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 17),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: Colors.white, width: 1.2),
            ),
            child: Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  size: 21,
                  color: AppColors.muted,
                  strokeWidth: 1.6,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const _CircleIconButton(icon: HugeIcons.strokeRoundedFilterHorizontal),
      ],
    );
  }
}

class _SegmentPills extends StatelessWidget {
  const _SegmentPills({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: i == 0 ? Colors.black : AppColors.panel,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: i == 0 ? Colors.black : Colors.white),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: i == 0 ? Colors.white : AppColors.muted,
                ),
              ),
            ),
            if (i != labels.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({
    required this.name,
    required this.source,
    required this.budget,
    required this.status,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String source;
  final String budget;
  final String status;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                name.characters.first,
                style: const TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$source · $budget',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.muted,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            _SmallStatusPill(text: status),
          ],
        ),
      ),
    );
  }
}

class _PropertyListCard extends StatelessWidget {
  const _PropertyListCard({
    required this.property,
    required this.onTap,
    this.onLongPress,
    this.enableHero = true,
  });

  final PropertyListing property;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: _GlassCard(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _OptionalHero(
                tag: property.heroTag,
                enabled: enableHero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _PropertyImage(
                    property: property,
                    width: 112,
                    height: 104,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SmallStatusPill(text: property.status),
                  const SizedBox(height: 10),
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontFamily: AppFonts.cabinet,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    property.price,
                    style: const TextStyle(
                      fontFamily: AppFonts.cabinet,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                ],
              ),
            ),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight02,
              size: 22,
              color: AppColors.ink,
              strokeWidth: 1.7,
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _PropertyViewToggle extends StatelessWidget {
  const _PropertyViewToggle({
    required this.isCardView,
    required this.onChanged,
  });

  final bool isCardView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ViewToggleButton(
          label: 'Card View',
          icon: HugeIcons.strokeRoundedGridView,
          selected: isCardView,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 8),
        _ViewToggleButton(
          label: 'List View',
          icon: HugeIcons.strokeRoundedListView,
          selected: !isCardView,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final List<List<dynamic>> icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.black : AppColors.panel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? Colors.black : Colors.white,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: icon,
                size: 19,
                color: selected ? Colors.white : AppColors.muted,
                strokeWidth: 1.7,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.muted,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PropertyFeedCard extends StatelessWidget {
  const _PropertyFeedCard({
    required this.property,
    required this.onTap,
    this.onLongPress,
    this.enableHero = true,
  });

  final PropertyListing property;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.panel.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.95),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB9C1B9).withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.74,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _OptionalHero(
                      tag: property.heroTag,
                      enabled: enableHero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _PropertyImage(
                          property: property,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 13,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: property.tagColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          property.status,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowExpandDiagonal02,
                            size: 19,
                            color: AppColors.ink,
                            strokeWidth: 1.7,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 58,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.05),
                                  Colors.black.withValues(alpha: 0.34),
                                ],
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    property.price,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.cabinet,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '/ ',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white.withValues(
                                              alpha: 0.72,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          property.oldPrice,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white.withValues(
                                              alpha: 0.72,
                                            ),
                                            decoration:
                                                TextDecoration.lineThrough,
                                            decorationColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 2),
              child: Text(
                property.title,
                style: const TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.7,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                property.location,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.muted,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
              child: Row(
                children: [
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Text(
                          'Property Viewed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const _ViewerCluster(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyAvatar extends StatelessWidget {
  const _TinyAvatar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Center(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedUser02,
          size: 15,
          color: AppColors.ink,
          strokeWidth: 1.7,
        ),
      ),
    );
  }
}

class _ViewerCluster extends StatelessWidget {
  const _ViewerCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Positioned(left: 0, child: _ViewerCountBubble()),
          Positioned(
            left: 28,
            top: 2,
            child: _TinyAvatar(color: Color(0xFFBDE0D3)),
          ),
          Positioned(
            left: 54,
            top: 2,
            child: _TinyAvatar(color: Color(0xFFF2B8C8)),
          ),
        ],
      ),
    );
  }
}

class _ViewerCountBubble extends StatelessWidget {
  const _ViewerCountBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFF071B1D),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        '+8',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FollowUpSummaryCard extends StatelessWidget {
  const _FollowUpSummaryCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          _SoftIcon(
            icon: HugeIcons.strokeRoundedCalendarCheckIn01,
            size: 56,
            iconSize: 26,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '14 due today',
                  style: TextStyle(
                    fontFamily: AppFonts.cabinet,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.9,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '3 overdue follow-ups need attention before 5 pm.',
                  style: TextStyle(fontSize: 14.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpTile extends StatelessWidget {
  const _FollowUpTile({
    required this.time,
    required this.name,
    required this.task,
    required this.method,
  });

  final String time;
  final String name;
  final String task;
  final String method;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 12),
                const _SoftIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  size: 42,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: AppFonts.cabinet,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    task,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.muted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SmallStatusPill(text: method),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _SoftIcon(icon: icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppFonts.cabinet,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.muted,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
            const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight02,
              size: 21,
              color: AppColors.muted,
              strokeWidth: 1.7,
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({required this.icon, this.size = 50, this.iconSize = 23});

  final List<List<dynamic>> icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.mint,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: HugeIcon(
          icon: icon,
          size: iconSize,
          color: AppColors.ink,
          strokeWidth: 1.65,
        ),
      ),
    );
  }
}

class _OptionalHero extends StatelessWidget {
  const _OptionalHero({
    required this.tag,
    required this.enabled,
    required this.child,
  });

  final String tag;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Hero(tag: tag, child: child);
  }
}

class _SmallStatusPill extends StatelessWidget {
  const _SmallStatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: AppColors.green,
          letterSpacing: -0.15,
        ),
      ),
    );
  }
}

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({required this.property, super.key});

  final PropertyListing property;

  static const fallbackProperty = PropertyListing(
    id: 'fallback-modern-house',
    title: 'Modern Simple House',
    location: '2510 S Congress Ave, TX 78704',
    price: r'$864,000',
    oldPrice: r'$910,000',
    status: 'Sale',
    image:
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=90',
    tagColor: AppColors.green,
  );

  static const _planImages = [
    'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=500&q=80',
    'https://images.unsplash.com/photo-1503389152951-9f343605f61e?auto=format&fit=crop&w=500&q=80',
    'https://images.unsplash.com/photo-1604014237800-1c9102c219da?auto=format&fit=crop&w=500&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
                children: [
                  const _ScreenHeader(),
                  const SizedBox(height: 28),
                  _HeroGallery(property: property),
                  const SizedBox(height: 12),
                  const _ThumbnailStrip(),
                  const SizedBox(height: 12),
                  const _SpecsCard(),
                  const SizedBox(height: 12),
                  _DetailsCard(property: property),
                  const SizedBox(height: 12),
                  _DescriptionCard(property: property),
                ],
              ),
            ),
            const Positioned(
              left: 18,
              right: 18,
              bottom: 12,
              child: _BottomActions(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: HugeIcons.strokeRoundedArrowLeft02,
          onTap: () => Navigator.maybePop(context),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Property Details',
              style: TextStyle(
                fontFamily: AppFonts.cabinet,
                fontSize: 27,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -1.3,
              ),
            ),
          ),
        ),
        Transform.rotate(
          angle: -0.2,
          child: const _CircleIconButton(icon: HugeIcons.strokeRoundedShare08),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final List<List<dynamic>> icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.panel.withValues(alpha: 0.62),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.88),
            width: 1.1,
          ),
        ),
        child: Center(
          child: HugeIcon(
            icon: icon,
            size: 24,
            color: AppColors.ink,
            strokeWidth: 1.7,
          ),
        ),
      ),
    );
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({required this.property});

  final PropertyListing property;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: property.heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: _PropertyImage(property: property, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: _Pill(
                text: property.status,
                background: AppColors.ink,
                color: Colors.white,
              ),
            ),
            const Positioned(
              right: 8,
              top: 8,
              child: _Pill(
                text: 'In Progress',
                background: AppColors.mint,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.color,
  });

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final image in PropertyDetailsScreen._planImages) ...[
          Expanded(child: _PlanThumb(image: image)),
          if (image != PropertyDetailsScreen._planImages.last)
            const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _PlanThumb extends StatelessWidget {
  const _PlanThumb({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white, width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white70,
              BlendMode.screen,
            ),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.line),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecsCard extends StatelessWidget {
  const _SpecsCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: _SpecItem(
              icon: HugeIcons.strokeRoundedEntranceStairs,
              label: 'Floor',
              value: '2',
            ),
          ),
          Expanded(
            child: _SpecItem(
              icon: HugeIcons.strokeRoundedBedDouble,
              label: 'Bedroom',
              value: '4',
            ),
          ),
          Expanded(
            child: _SpecItem(
              icon: HugeIcons.strokeRoundedBathtub01,
              label: 'Bathroom',
              value: '3',
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final List<List<dynamic>> icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.mint,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: 25,
              color: AppColors.ink,
              strokeWidth: 1.65,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppFonts.cabinet,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.property});

  final PropertyListing property;

  @override
  Widget build(BuildContext context) {
    final rows = [
      _DetailRow(
        icon: HugeIcons.strokeRoundedTag02,
        label: 'Request Type',
        value: property.status,
      ),
      const _DetailRow(
        icon: HugeIcons.strokeRoundedCalendar03,
        label: 'Year Build',
        value: '2016',
      ),
      _DetailRow(
        icon: HugeIcons.strokeRoundedBriefcase02,
        label: 'Account',
        value: property.title,
      ),
      const _DetailRow(
        icon: HugeIcons.strokeRoundedUser02,
        label: 'Contacts',
        value: 'Frederick Graham',
      ),
      _DetailRow(
        icon: HugeIcons.strokeRoundedMaps,
        label: 'Location',
        value: property.location.split(',').first,
      ),
      _DetailRow(
        icon: HugeIcons.strokeRoundedLocation01,
        label: 'Address',
        value: property.location,
      ),
    ];

    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        children: [
          const _CardTitle(title: 'Details'),
          const SizedBox(height: 22),
          ...rows,
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.cabinet,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -0.7,
          ),
        ),
        const Spacer(),
        const HugeIcon(
          icon: HugeIcons.strokeRoundedMoreVertical,
          size: 24,
          color: AppColors.ink,
          strokeWidth: 1.7,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final List<List<dynamic>> icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            size: 22,
            color: AppColors.muted,
            strokeWidth: 1.55,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.muted,
                letterSpacing: -0.25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppFonts.cabinet,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.property});

  final PropertyListing property;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(title: 'Description'),
          const SizedBox(height: 16),
          Text(
            '${property.title} is listed at ${property.price} in ${property.location}. This demo record is now shared across the card view, list view, and details page so the selected inventory item stays consistent.',
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.55,
              color: AppColors.muted,
              letterSpacing: -0.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.panel.withValues(alpha: 0.97),
            AppColors.panelSoft.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.88),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            blurRadius: 22,
            offset: const Offset(-8, -8),
          ),
          BoxShadow(
            color: const Color(0xFFB9C1B9).withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Download',
              style: TextStyle(
                fontFamily: AppFonts.cabinet,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Print',
              style: TextStyle(
                fontFamily: AppFonts.cabinet,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

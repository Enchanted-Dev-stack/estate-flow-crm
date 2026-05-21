import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

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

  static const _screens = [
    DashboardScreen(),
    LeadsScreen(),
    PropertiesScreen(),
    FollowUpsScreen(),
    MoreScreen(),
  ];

  static const _items = [
    _NavItem('Dashboard', HugeIcons.strokeRoundedHome05),
    _NavItem('Leads', HugeIcons.strokeRoundedUserGroup),
    _NavItem('Properties', HugeIcons.strokeRoundedBuilding03),
    _NavItem('Follow-ups', HugeIcons.strokeRoundedCalendar03),
    _NavItem('More', HugeIcons.strokeRoundedMenuCircle),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: _screens[_selectedIndex]),
            Positioned(
              left: 18,
              right: 18,
              bottom: 12,
              child: _BottomNavBar(
                items: _items,
                selectedIndex: _selectedIndex,
                onChanged: (index) => setState(() => _selectedIndex = index),
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
  const _BottomNavBar({required this.items, required this.selectedIndex, required this.onChanged});

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.panel.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 28, offset: const Offset(0, 14)),
        ],
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == index ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: items[index].icon,
                        size: 22,
                        color: selectedIndex == index ? Colors.white : AppColors.muted,
                        strokeWidth: 1.7,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selectedIndex == index ? items[index].label : '',
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppScreen extends StatelessWidget {
  const AppScreen({required this.title, required this.subtitle, required this.children, this.actionIcon, this.onAction, super.key});

  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<List<dynamic>>? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 104),
      children: [
        AppHeader(title: title, subtitle: subtitle, actionIcon: actionIcon, onAction: onAction),
        const SizedBox(height: 22),
        ...children,
      ],
    );
  }
}

class AppHeader extends StatelessWidget {
  const AppHeader({required this.title, required this.subtitle, this.actionIcon, this.onAction, super.key});

  final String title;
  final String subtitle;
  final List<List<dynamic>>? actionIcon;
  final VoidCallback? onAction;

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
                style: const TextStyle(fontSize: 15, color: AppColors.muted, letterSpacing: -0.2),
              ),
            ],
          ),
        ),
        _CircleIconButton(icon: actionIcon ?? HugeIcons.strokeRoundedNotification01, onTap: onAction),
      ],
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'EstateFlow',
      subtitle: 'Today\'s real estate command center',
      children: [
        const _HeroMetricCard(),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: _MiniMetricCard(label: 'New leads', value: '18', icon: HugeIcons.strokeRoundedUserAdd01)),
            SizedBox(width: 10),
            Expanded(child: _MiniMetricCard(label: 'Calls due', value: '42', icon: HugeIcons.strokeRoundedCall02)),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(child: _MiniMetricCard(label: 'Hot leads', value: '7', icon: HugeIcons.strokeRoundedFire)),
            SizedBox(width: 10),
            Expanded(child: _MiniMetricCard(label: 'Inventory', value: '64', icon: HugeIcons.strokeRoundedBuilding03)),
          ],
        ),
        const SizedBox(height: 12),
        _SectionHeader(title: 'Recent activity', action: 'View all'),
        const SizedBox(height: 10),
        const _ActivityTile(icon: HugeIcons.strokeRoundedMessage01, title: 'Property details shared', meta: 'Rahul Sharma · 12 min ago'),
        const _ActivityTile(icon: HugeIcons.strokeRoundedCalendarCheckIn01, title: 'Site visit scheduled', meta: 'DLF Phase 3 · 2:30 pm'),
        const _ActivityTile(icon: HugeIcons.strokeRoundedUserCheck01, title: 'New hot lead assigned', meta: 'Priya Mehta · Instagram'),
      ],
    );
  }
}

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Leads',
      subtitle: 'Qualify buyers and track every touchpoint',
      actionIcon: HugeIcons.strokeRoundedAdd01,
      children: [
        const _SearchFilterBar(hint: 'Search leads, phone or source'),
        const SizedBox(height: 14),
        const _SegmentPills(labels: ['All', 'Hot', 'New', 'Visit', 'Won']),
        const SizedBox(height: 14),
        _LeadCard(name: 'Rahul Sharma', source: '36 Acre', budget: '₹75L - ₹1.2Cr', status: 'Hot', color: AppColors.mint, onTap: () {}),
        const SizedBox(height: 10),
        _LeadCard(name: 'Priya Mehta', source: 'Instagram', budget: '3BHK · Gurgaon', status: 'New', color: AppColors.panel, onTap: () {}),
        const SizedBox(height: 10),
        _LeadCard(name: 'Aman Verma', source: 'MagicBricks', budget: 'Plot · South Delhi', status: 'Follow-up', color: AppColors.panel, onTap: () {}),
      ],
    );
  }
}

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  bool _isCardView = true;

  static const _properties = [
    PropertyListing(
      title: 'Entire rental unit in Avelengo',
      location: '305 Pomona Ave, Coronado, CA. 92118',
      price: r'$2,500,000',
      oldPrice: r'$2,550,000',
      status: 'Sale',
      image: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1000&q=90',
      tagColor: Color(0xFFE46773),
    ),
    PropertyListing(
      title: 'Single family house in Coronado',
      location: '305 Pomona Ave, Coronado, CA. 92118',
      price: r'$3,600',
      oldPrice: r'$3,950',
      status: 'Rental',
      image: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1000&q=90',
      tagColor: Color(0xFF36C878),
    ),
    PropertyListing(
      title: 'Skyline Apartment near Expressway',
      location: 'Noida Sector 150, Uttar Pradesh',
      price: r'$920,000',
      oldPrice: r'$960,000',
      status: 'Ready',
      image: 'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?auto=format&fit=crop&w=1000&q=90',
      tagColor: AppColors.green,
    ),
  ];

  void _openDetails() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PropertyDetailsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Properties',
      subtitle: 'Inventory, availability and shareable listings',
      actionIcon: HugeIcons.strokeRoundedAdd01,
      children: [
        const _SearchFilterBar(hint: 'Search location, budget or type'),
        const SizedBox(height: 14),
        _PropertyViewToggle(
          isCardView: _isCardView,
          onChanged: (value) => setState(() => _isCardView = value),
        ),
        const SizedBox(height: 14),
        if (_isCardView) ...[
          for (final property in _properties) ...[
            _PropertyFeedCard(property: property, onTap: _openDetails),
            if (property != _properties.last) const SizedBox(height: 12),
          ],
        ] else ...[
          for (final property in _properties) ...[
            _PropertyListCard(property: property, onTap: _openDetails),
            if (property != _properties.last) const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class PropertyListing {
  const PropertyListing({
    required this.title,
    required this.location,
    required this.price,
    required this.oldPrice,
    required this.status,
    required this.image,
    required this.tagColor,
  });

  final String title;
  final String location;
  final String price;
  final String oldPrice;
  final String status;
  final String image;
  final Color tagColor;
}

class FollowUpsScreen extends StatelessWidget {
  const FollowUpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Follow-ups',
      subtitle: 'Calls, reminders and WhatsApp nudges due today',
      actionIcon: HugeIcons.strokeRoundedCalendarAdd01,
      children: const [
        _FollowUpSummaryCard(),
        SizedBox(height: 12),
        _FollowUpTile(time: '10:30 am', name: 'Rahul Sharma', task: 'Send 3BHK Golf Course options', method: 'WhatsApp'),
        _FollowUpTile(time: '12:00 pm', name: 'Priya Mehta', task: 'Confirm Saturday site visit', method: 'Call'),
        _FollowUpTile(time: '4:15 pm', name: 'Aman Verma', task: 'Share revised price sheet', method: 'Email'),
      ],
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'More',
      subtitle: 'Operations, team and admin settings',
      actionIcon: HugeIcons.strokeRoundedSettings01,
      children: const [
        _MoreTile(icon: HugeIcons.strokeRoundedLocation01, title: 'Attendance', subtitle: 'Check-ins, field visits and GPS history'),
        _MoreTile(icon: HugeIcons.strokeRoundedCalendar03, title: 'Site Visits', subtitle: 'Upcoming property tours and visit notes'),
        _MoreTile(icon: HugeIcons.strokeRoundedInstagram, title: 'Social Media', subtitle: 'Content calendar and scheduled posts'),
        _MoreTile(icon: HugeIcons.strokeRoundedUserGroup, title: 'Team', subtitle: 'Invite members and manage roles'),
        _MoreTile(icon: HugeIcons.strokeRoundedSettings02, title: 'Integrations', subtitle: 'WhatsApp, storage and future voice agents'),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(18)),
                child: const Text(
                  '+18% this week',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green),
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
          const Text('Pipeline value across 46 active opportunities', style: TextStyle(fontSize: 15, color: AppColors.muted)),
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
  const _MiniMetricCard({required this.label, required this.value, required this.icon});

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
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.muted, letterSpacing: -0.2)),
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
          style: const TextStyle(fontFamily: AppFonts.cabinet, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.7),
        ),
        const Spacer(),
        Text(action, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.green)),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.icon, required this.title, required this.meta});

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
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text(meta, style: const TextStyle(fontSize: 13.5, color: AppColors.muted, letterSpacing: -0.15)),
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
                const HugeIcon(icon: HugeIcons.strokeRoundedSearch01, size: 21, color: AppColors.muted, strokeWidth: 1.6),
                const SizedBox(width: 10),
                Expanded(child: Text(hint, style: const TextStyle(fontSize: 14.5, color: AppColors.muted))),
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
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: i == 0 ? Colors.white : AppColors.muted),
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
  const _LeadCard({required this.name, required this.source, required this.budget, required this.status, required this.color, required this.onTap});

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
                style: const TextStyle(fontFamily: AppFonts.cabinet, fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.4)),
                  const SizedBox(height: 4),
                  Text('$source · $budget', style: const TextStyle(fontSize: 13.5, color: AppColors.muted, letterSpacing: -0.2)),
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
  const _PropertyListCard({required this.property, required this.onTap});

  final PropertyListing property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                property.image,
                width: 112,
                height: 104,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(width: 112, height: 104, color: AppColors.line),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SmallStatusPill(text: property.status),
                  const SizedBox(height: 10),
                  Text(property.title, style: const TextStyle(fontFamily: AppFonts.cabinet, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.7)),
                  const SizedBox(height: 4),
                  Text(property.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  Text(property.price, style: const TextStyle(fontFamily: AppFonts.cabinet, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
                ],
              ),
            ),
            const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight02, size: 22, color: AppColors.ink, strokeWidth: 1.7),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _PropertyViewToggle extends StatelessWidget {
  const _PropertyViewToggle({required this.isCardView, required this.onChanged});

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
  const _ViewToggleButton({required this.label, required this.icon, required this.selected, required this.onTap});

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
            border: Border.all(color: selected ? Colors.black : Colors.white, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(icon: icon, size: 19, color: selected ? Colors.white : AppColors.muted, strokeWidth: 1.7),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.muted, letterSpacing: -0.2),
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
  });

  final PropertyListing property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.panel.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.95), width: 1.2),
          boxShadow: [
            BoxShadow(color: const Color(0xFFB9C1B9).withValues(alpha: 0.18), blurRadius: 28, offset: const Offset(0, 14)),
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
                    Image.network(
                      property.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: AppColors.line),
                    ),
                    Positioned(
                      left: 13,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(color: property.tagColor, borderRadius: BorderRadius.circular(16)),
                        child: Text(property.status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                        child: const Center(
                          child: HugeIcon(icon: HugeIcons.strokeRoundedArrowExpandDiagonal02, size: 19, color: AppColors.ink, strokeWidth: 1.7),
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
                                colors: [Colors.white.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.34)],
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
                                    child: Text(
                                      '/ ${property.oldPrice}',
                                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.72), decoration: TextDecoration.lineThrough),
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
                style: const TextStyle(fontFamily: AppFonts.cabinet, fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.7),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(property.location, style: const TextStyle(fontSize: 13.5, color: AppColors.muted, letterSpacing: -0.2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
              child: Row(
                children: [
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Text(
                          'Property Viewed',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.ink),
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
        child: HugeIcon(icon: HugeIcons.strokeRoundedUser02, size: 15, color: AppColors.ink, strokeWidth: 1.7),
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
          Positioned(
            left: 0,
            child: _ViewerCountBubble(),
          ),
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
      decoration: const BoxDecoration(color: Color(0xFF071B1D), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: const Text('+8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
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
          _SoftIcon(icon: HugeIcons.strokeRoundedCalendarCheckIn01, size: 56, iconSize: 26),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('14 due today', style: TextStyle(fontFamily: AppFonts.cabinet, fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: -0.9)),
                SizedBox(height: 4),
                Text('3 overdue follow-ups need attention before 5 pm.', style: TextStyle(fontSize: 14.5, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpTile extends StatelessWidget {
  const _FollowUpTile({required this.time, required this.name, required this.task, required this.method});

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
                Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.muted)),
                const SizedBox(height: 12),
                const _SoftIcon(icon: HugeIcons.strokeRoundedClock01, size: 42, iconSize: 20),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontFamily: AppFonts.cabinet, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 5),
                  Text(task, style: const TextStyle(fontSize: 14.5, color: AppColors.muted, height: 1.35)),
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
  const _MoreTile({required this.icon, required this.title, required this.subtitle});

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
                  Text(title, style: const TextStyle(fontFamily: AppFonts.cabinet, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13.5, color: AppColors.muted, letterSpacing: -0.1)),
                ],
              ),
            ),
            const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight02, size: 21, color: AppColors.muted, strokeWidth: 1.7),
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
      decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
      child: Center(child: HugeIcon(icon: icon, size: iconSize, color: AppColors.ink, strokeWidth: 1.65)),
    );
  }
}

class _SmallStatusPill extends StatelessWidget {
  const _SmallStatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.green, letterSpacing: -0.15)),
    );
  }
}

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key});

  static const _heroImage =
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=90';

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
                children: const [
                  _ScreenHeader(),
                  SizedBox(height: 28),
                  _HeroGallery(),
                  SizedBox(height: 12),
                  _ThumbnailStrip(),
                  SizedBox(height: 12),
                  _SpecsCard(),
                  SizedBox(height: 12),
                  _DetailsCard(),
                  SizedBox(height: 12),
                  _DescriptionCard(),
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
        _CircleIconButton(icon: HugeIcons.strokeRoundedArrowLeft02, onTap: () => Navigator.maybePop(context)),
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
          border: Border.all(color: AppColors.line),
        ),
        child: Center(
          child: HugeIcon(icon: icon, size: 24, color: AppColors.ink, strokeWidth: 1.7),
        ),
      ),
    );
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              PropertyDetailsScreen._heroImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.line),
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
                    colors: [Colors.black.withValues(alpha: 0.18), Colors.transparent],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 8,
              top: 8,
              child: _Pill(text: 'Separate Hous', background: AppColors.ink, color: Colors.white),
            ),
            const Positioned(
              right: 8,
              top: 8,
              child: _Pill(text: 'In Progress', background: AppColors.mint, color: AppColors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.background, required this.color});

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
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color, letterSpacing: -0.3),
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
          if (image != PropertyDetailsScreen._planImages.last) const SizedBox(width: 8),
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
            colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.screen),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.line),
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
          Expanded(child: _SpecItem(icon: HugeIcons.strokeRoundedStairs02, label: 'Floor', value: '2')),
          Expanded(child: _SpecItem(icon: HugeIcons.strokeRoundedBed, label: 'Bedroom', value: '4')),
          Expanded(child: _SpecItem(icon: HugeIcons.strokeRoundedBathtub01, label: 'Bathroom', value: '3')),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  const _SpecItem({required this.icon, required this.label, required this.value});

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
          decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
          child: Center(
            child: HugeIcon(icon: icon, size: 25, color: AppColors.ink, strokeWidth: 1.65),
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
                style: const TextStyle(fontSize: 14, color: AppColors.muted, letterSpacing: -0.2),
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
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    const rows = [
      _DetailRow(icon: HugeIcons.strokeRoundedTag02, label: 'Request Type', value: 'Sale'),
      _DetailRow(icon: HugeIcons.strokeRoundedCalendar03, label: 'Year Build', value: '2016'),
      _DetailRow(icon: HugeIcons.strokeRoundedBriefcase02, label: 'Account', value: 'Serenity Haven'),
      _DetailRow(icon: HugeIcons.strokeRoundedUser02, label: 'Contacts', value: 'Frederick Graham'),
      _DetailRow(icon: HugeIcons.strokeRoundedMaps, label: 'Location', value: 'South Austin'),
      _DetailRow(icon: HugeIcons.strokeRoundedLocation01, label: 'Address', value: '2510 S Congress Ave, TX 78704'),
    ];

    return const _GlassCard(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        children: [
          _CardTitle(title: 'Details'),
          SizedBox(height: 22),
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
        const HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, size: 24, color: AppColors.ink, strokeWidth: 1.7),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final List<List<dynamic>> icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          HugeIcon(icon: icon, size: 22, color: AppColors.muted, strokeWidth: 1.55),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: AppColors.muted, letterSpacing: -0.25),
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
  const _DescriptionCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(title: 'Description'),
          SizedBox(height: 16),
          Text(
            'Minimal contemporary villa with clean elevations, wide glazing, warm wood accents and a quiet residential setting. Ideal for high-intent buyers looking for a ready-to-move premium home.',
            style: TextStyle(fontSize: 15.5, height: 1.55, color: AppColors.muted, letterSpacing: -0.25),
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
          colors: [AppColors.panel.withValues(alpha: 0.97), AppColors.panelSoft.withValues(alpha: 0.96)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88), width: 1.3),
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
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 6)),
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
                BoxShadow(color: Colors.black.withValues(alpha: 0.24), blurRadius: 22, offset: const Offset(0, 10)),
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

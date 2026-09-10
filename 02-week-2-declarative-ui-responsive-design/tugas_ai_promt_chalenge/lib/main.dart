import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_grid_view.dart';
import 'screens/dashboard_layout_builder.dart';
import 'screens/tradeoff_screen.dart';

void main() {
  runApp(const AcademicApp());
}

class AcademicApp extends StatefulWidget {
  const AcademicApp({super.key});

  @override
  State<AcademicApp> createState() => _AcademicAppState();
}

class _AcademicAppState extends State<AcademicApp> {
  bool _isDark = false;
  double _textScaleFactor = 1.0;
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal & Dashboard Akademik Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        // Accessibility Text Scaler Injection
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_textScaleFactor),
          ),
          child: child!,
        );
      },
      home: _isLoggedIn
          ? AcademicDashboardHost(
              isDark: _isDark,
              onDarkChanged: (val) => setState(() => _isDark = val),
              textScaleFactor: _textScaleFactor,
              onTextScaleChanged: (val) => setState(() => _textScaleFactor = val),
              onLogout: () => setState(() => _isLoggedIn = false),
            )
          : AestheticStudentLoginScreen(
              isDark: _isDark,
              onDarkChanged: (val) => setState(() => _isDark = val),
              onLoginSuccess: () => setState(() => _isLoggedIn = true),
            ),
    );
  }
}

class AcademicDashboardHost extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;
  final double textScaleFactor;
  final ValueChanged<double> onTextScaleChanged;
  final VoidCallback onLogout;

  const AcademicDashboardHost({
    super.key,
    required this.isDark,
    required this.onDarkChanged,
    required this.textScaleFactor,
    required this.onTextScaleChanged,
    required this.onLogout,
  });

  @override
  State<AcademicDashboardHost> createState() => _AcademicDashboardHostState();
}

class _AcademicDashboardHostState extends State<AcademicDashboardHost> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardGridViewScreen(),
    DashboardLayoutBuilderScreen(),
    TradeOffAnalysisScreen(),
  ];

  void _showAccessibilityTester(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.accessibility_new_rounded, color: Colors.indigo),
                      const SizedBox(width: 12),
                      Text(
                        'Simulator Aksesibilitas Skala Teks',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uji ketahanan tata letak GridView vs LayoutBuilder ketika pengguna tunanetra/low-vision memperbesar ukuran teks font di perangkat.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Faktor Skala Teks:'),
                      Chip(
                        label: Text('${widget.textScaleFactor.toStringAsFixed(1)}x'),
                      ),
                    ],
                  ),
                  Slider(
                    value: widget.textScaleFactor,
                    min: 0.8,
                    max: 1.8,
                    divisions: 10,
                    label: '${widget.textScaleFactor.toStringAsFixed(1)}x',
                    onChanged: (val) {
                      setSheetState(() {});
                      widget.onTextScaleChanged(val);
                    },
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Terapkan & Tutup'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    final appTitles = [
      'Dashboard (GridView)',
      'Dashboard (LayoutBuilder + Col)',
      'Analisis Trade-Off Arsitektur',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appTitles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Accessibility Text Scaler Tester Button
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Uji Skala Teks Aksesibilitas',
            onPressed: () => _showAccessibilityTester(context),
          ),
          // Theme Switcher
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: widget.isDark ? 'Mode Terang' : 'Mode Gelap',
            onPressed: () => widget.onDarkChanged(!widget.isDark),
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar Portal Mahasiswa',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Keluar'),
                  content: const Text('Apakah Anda yakin ingin keluar dari portal akademik mahasiswa?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onLogout();
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.school_rounded, color: colorScheme.primary),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: Text('GridView'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.layers_outlined),
                      selectedIcon: Icon(Icons.layers_rounded),
                      label: Text('LayoutBuilder'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.compare_arrows_outlined),
                      selectedIcon: Icon(Icons.compare_arrows_rounded),
                      label: Text('Trade-Off'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _pages[_selectedIndex]),
              ],
            )
          : _pages[_selectedIndex],
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'GridView',
                ),
                NavigationDestination(
                  icon: Icon(Icons.layers_outlined),
                  selectedIcon: Icon(Icons.layers_rounded),
                  label: 'LayoutBuilder',
                ),
                NavigationDestination(
                  icon: Icon(Icons.compare_arrows_outlined),
                  selectedIcon: Icon(Icons.compare_arrows_rounded),
                  label: 'Trade-Off',
                ),
              ],
            ),
    );
  }
}

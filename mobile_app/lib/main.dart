import 'package:flutter/material.dart';
import 'views/attendance_screen.dart';
import 'views/tabs/customer_manager_tab.dart';
import 'views/tabs/material_calculator_tab.dart';
import 'views/tabs/price_list_catalog_tab.dart';
import 'views/tabs/product_selector_tab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProductManagerMobileApp());
}

// ===========================================================================
// MAIN APP & MATERIAL 3 THEME
// ===========================================================================

class ProductManagerMobileApp extends StatelessWidget {
  const ProductManagerMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Selector & Material Estimator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F5D9F), // Primary brand from desktop UI
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2F5D9F), width: 1.8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const ProductManagerMainHub(),
    );
  }
}

// ===========================================================================
// MAIN NAVIGATION HUB (CONVERTED FROM DESKTOP NOTEBOOK TABS)
// ===========================================================================

class ProductManagerMainHub extends StatefulWidget {
  const ProductManagerMainHub({super.key});

  @override
  State<ProductManagerMainHub> createState() => _ProductManagerMainHubState();
}

class _ProductManagerMainHubState extends State<ProductManagerMainHub> {
  int _currentNavIndex = 0;

  final List<String> _titles = [
    'Product Price Lookup',
    'Material & Labor Calculator',
    'Price List Catalog',
    'Customer Directory',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _titles[_currentNavIndex],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              'Booster Pump Panel & Water Meter Estimator',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'System Info',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Product Selector Mobile',
                applicationVersion: '1.0.0 (Mobile Edition)',
                applicationLegalese: '© Saark Operating System',
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Native Flutter mobile conversion of the desktop Product Manager, '
                    'Price Estimator, and BOM Material Engine.',
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          ProductSelectorTab(
            onNavigateToBOM: () => setState(() => _currentNavIndex = 1),
          ),
          const MaterialCalculatorTab(),
          const PriceListCatalogTab(),
          const CustomerManagerTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) => setState(() => _currentNavIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Selector',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'BOM Engine',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_list_bulleted_rounded),
            selectedIcon: Icon(Icons.view_list_rounded),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Customers',
          ),
        ],
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text(
              'Product Manager & Estimator',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('Saark Operating System • Mobile Suite'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.electric_bolt_rounded,
                  size: 38, color: Color(0xFF2F5D9F)),
            ),
            decoration: BoxDecoration(color: Color(0xFF2F5D9F)),
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Product Price Lookup (Tab 1)'),
            selected: _currentNavIndex == 0,
            onTap: () {
              setState(() => _currentNavIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate_rounded),
            title: const Text('Material & Labor Calculator (Tab 2)'),
            selected: _currentNavIndex == 1,
            onTap: () {
              setState(() => _currentNavIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_list_bulleted_rounded),
            title: const Text('Price List Catalog (CSV Viewer)'),
            selected: _currentNavIndex == 2,
            onTap: () {
              setState(() => _currentNavIndex = 2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_rounded),
            title: const Text('Customer Directory & Adjustments'),
            selected: _currentNavIndex == 3,
            onTap: () {
              setState(() => _currentNavIndex = 3);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.fingerprint_rounded),
            title: const Text('Biometric Attendance Module'),
            subtitle: const Text('From attendance_window.py'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AttendanceScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

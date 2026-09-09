import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'sales/sales_module_screen.dart';
import 'production/production_screen.dart';
import 'accounts/accounts_finance_screen.dart';
import 'hr/hr_screen.dart';
import 'attendance_screen.dart';
import 'warehouse/warehouse_screen.dart';
import 'qc/qc_qa_screen.dart';
import 'customer_service/customer_service_screen.dart';
import 'panel_mfg/panel_mfg_screen.dart';
import 'rnd/rnd_screen.dart';
import 'supply_chain/supply_chain_screen.dart';
import 'maintenance/maintenance_screen.dart';
import 'it/it_workspace_screen.dart';
import 'admin/admin_access_control_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _auth = AuthService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const LoginScreen();
    }

    // Full module definitions matching main.py all_modules list
    final allModules = [
      _ModuleItem(
        permKey: 'allow_sales',
        title: 'Sales & Marketing',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF2563EB),
        subtitle: 'Price Search, CRM & Water Meters',
        builder: (_) => const SalesModuleScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_production',
        title: 'Production Process',
        icon: Icons.precision_manufacturing_rounded,
        color: const Color(0xFFD97706),
        subtitle: 'Batches, Stage Stepper & Tracking',
        builder: (_) => const ProductionScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_panel_mfg',
        title: 'Panel Manufacturing',
        icon: Icons.developer_board_rounded,
        color: const Color(0xFF7C3AED),
        subtitle: 'Enclosures, IP Specs & Job Sheets',
        builder: (_) => const PanelMfgScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_accounts',
        title: 'Accounts & Finance',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF059669),
        subtitle: 'Ledgers, Income & Expenses',
        builder: (_) => const AccountsFinanceScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_hr',
        title: 'Human Resources (HR)',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFFDB2777),
        subtitle: 'Staff Directory, Payroll & Leave',
        builder: (_) => const HrScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_attendance',
        title: 'Biometric Attendance',
        icon: Icons.fingerprint_rounded,
        color: const Color(0xFF0284C7),
        subtitle: 'Clock In/Out & Device Logs',
        builder: (_) => const AttendanceScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_stores',
        title: 'Stores / Warehouse',
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFEA580C),
        subtitle: 'Stock Inventory & Min Levels',
        builder: (_) => const WarehouseScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_qc_qa',
        title: 'Quality Control (QC/QA)',
        icon: Icons.fact_check_rounded,
        color: const Color(0xFF16A34A),
        subtitle: 'Panel Inspection & Defect Logs',
        builder: (_) => const QcQaScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_customer_service',
        title: 'Customer Service',
        icon: Icons.headset_mic_rounded,
        color: const Color(0xFF4F46E5),
        subtitle: 'Support Tickets & Ticket Desk',
        builder: (_) => const CustomerServiceScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_rnd',
        title: 'R&D / Engineering',
        icon: Icons.science_rounded,
        color: const Color(0xFF9333EA),
        subtitle: 'PDLC Roadmap & ECO Change Orders',
        builder: (_) => const RndScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_supply_chain',
        title: 'Supply Chain & Logistics',
        icon: Icons.local_shipping_rounded,
        color: const Color(0xFF0891B2),
        subtitle: 'Vendor Directory & Outward Dispatch',
        builder: (_) => const SupplyChainScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_maintenance',
        title: 'Equipment Maintenance',
        icon: Icons.build_rounded,
        color: const Color(0xFF65A30D),
        subtitle: 'Machine Status & Service Logs',
        builder: (_) => const MaintenanceScreen(),
      ),
      _ModuleItem(
        permKey: 'allow_it',
        title: 'IT Workspace Assets',
        icon: Icons.computer_rounded,
        color: const Color(0xFF3B82F6),
        subtitle: 'Hardware Inventory & Access Rights',
        builder: (_) => const ItWorkspaceScreen(),
      ),
    ];

    // Filter modules based on logged in user permissions
    final visibleModules = allModules.where((m) {
      final matchesPerm = _auth.hasPermission(m.permKey);
      final matchesSearch = _searchQuery.isEmpty ||
          m.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesPerm && matchesSearch;
    }).toList();

    // Include Admin Settings if user is Admin or has allow_admin
    final showAdmin = _auth.hasPermission('allow_admin');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3B66),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.fullName.isNotEmpty ? user.fullName : user.username}!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Role: ${user.role} • Select a workspace module',
              style: TextStyle(fontSize: 11, color: Colors.blue.shade100),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              _auth.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, visibleModules, showAdmin),
      body: CustomScrollView(
        slivers: [
          // Banner Card
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2F5D9F), Color(0xFF1F3B66)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1F3B66).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: Colors.amber, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Saark Operating System Mobile Hub',
                        style: TextStyle(
                          color: Colors.blue.shade100,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Company Management & Estimator Suite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search input
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search modules (e.g. Sales, CRM, BOM)...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF2F5D9F)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Modules Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Authorized Modules',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Chip(
                    label: Text(
                      '${visibleModules.length + (showAdmin ? 1 : 0)} Active',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F5D9F),
                      ),
                    ),
                    backgroundColor: Colors.blue.shade50,
                  ),
                ],
              ),
            ),
          ),

          // Module Cards Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < visibleModules.length) {
                    final item = visibleModules[index];
                    return _buildModuleCard(context, item);
                  } else if (showAdmin && index == visibleModules.length) {
                    return _buildAdminCard(context);
                  }
                  return const SizedBox.shrink();
                },
                childCount: visibleModules.length + (showAdmin ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, _ModuleItem item) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: item.builder),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      height: 1.2,
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

  Widget _buildAdminCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2F5D9F), width: 1.2),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminAccessControlScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5D9F).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings_suggest_rounded,
                    color: Color(0xFF2F5D9F), size: 28),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚙️ Admin Access',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2F5D9F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'User credentials & 24+ module permission toggles',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      height: 1.2,
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

  Widget _buildDrawer(BuildContext context, List<_ModuleItem> visibleModules, bool showAdmin) {
    final user = _auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.fullName.isNotEmpty == true ? user!.fullName : user?.username ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('Role: ${user?.role} • Mobile Suite'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.username.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F5D9F)),
              ),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1F3B66),
            ),
          ),
          ...visibleModules.map((m) => ListTile(
                leading: Icon(m.icon, color: m.color),
                title: Text(m.title),
                subtitle: Text(m.subtitle, style: const TextStyle(fontSize: 10)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: m.builder),
                  );
                },
              )),
          if (showAdmin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_rounded, color: Color(0xFF2F5D9F)),
              title: const Text('Admin Settings & User Permissions'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminAccessControlScreen()),
                );
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _auth.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModuleItem {
  final String permKey;
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;
  final WidgetBuilder builder;

  _ModuleItem({
    required this.permKey,
    required this.title,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.builder,
  });
}

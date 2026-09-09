import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../widgets/mobile_header.dart';

class AdminAccessControlScreen extends StatefulWidget {
  const AdminAccessControlScreen({super.key});

  @override
  State<AdminAccessControlScreen> createState() =>
      _AdminAccessControlScreenState();
}

class _AdminAccessControlScreenState extends State<AdminAccessControlScreen> {
  final AuthService _auth = AuthService();

  UserModel? _selectedUser;
  late TextEditingController _usernameCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _passwordCtrl;
  String _role = 'User';
  late Map<String, bool> _permissions;

  final List<MapEntry<String, String>> _moduleDefs = const [
    MapEntry('allow_price', 'Price List Search Tab'),
    MapEntry('allow_material', 'Material & Labor Calculator Tab'),
    MapEntry('allow_crm', 'Customer CRM & Leads Tab'),
    MapEntry('allow_sales', '📈 Sales & Marketing Module'),
    MapEntry('allow_production', '🏭 Production Process Module'),
    MapEntry('allow_project_management', '📁 Project Management'),
    MapEntry('allow_qc_qa', '✅ Quality Control (QC/QA)'),
    MapEntry('allow_panel_mfg', '🔧 Panel Manufacturing Module'),
    MapEntry('allow_accounts', '💰 Accounts & Finance Module'),
    MapEntry('allow_hr', '👥 HR (Human Resources) Module'),
    MapEntry('allow_attendance', '🕘 Attendance Module'),
    MapEntry('allow_purchase', '🛒 Purchase / Procurement Module'),
    MapEntry('allow_stores', '📦 Stores / Warehouse Module'),
    MapEntry('allow_maintenance', '🛠️ Maintenance Module'),
    MapEntry('allow_rnd', '🔬 R&D / Engineering Module'),
    MapEntry('allow_asset_management', '🏢 Asset Management'),
    MapEntry('allow_ehs', '🛡️ EHS / Risk Management'),
    MapEntry('allow_pos_ecommerce', '🛍️ POS / E-Commerce'),
    MapEntry('allow_it', '💻 IT Module'),
    MapEntry('allow_customer_service', '🎧 Customer Service Module'),
    MapEntry('allow_legal', '⚖️ Legal & Compliance Module'),
    MapEntry('allow_admin_dept', '📋 Administration Module'),
    MapEntry('allow_supply_chain', '🚚 Supply Chain / Logistics Module'),
    MapEntry('allow_admin', '⚙️ Admin Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _mobileCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _permissions = UserModel.defaultPermissions();
    _loadUser(_auth.allUsers.first);
  }

  void _loadUser(UserModel user) {
    setState(() {
      _selectedUser = user;
      _usernameCtrl.text = user.username;
      _nameCtrl.text = user.fullName;
      _mobileCtrl.text = user.mobileNumber;
      _passwordCtrl.text = '';
      _role = user.role;
      _permissions = Map.from(user.permissions);
    });
  }

  void _clearFieldsForNewUser() {
    setState(() {
      _selectedUser = null;
      _usernameCtrl.text = '';
      _nameCtrl.text = '';
      _mobileCtrl.text = '';
      _passwordCtrl.text = '';
      _role = 'User';
      _permissions = UserModel.defaultPermissions();
    });
  }

  void _saveUser() {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is required!')),
      );
      return;
    }

    final updated = UserModel(
      username: username,
      password: _passwordCtrl.text.isNotEmpty
          ? _passwordCtrl.text.trim()
          : (_selectedUser?.password ?? '123456'),
      fullName: _nameCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      role: _role,
      permissions: _permissions,
    );

    _auth.addOrUpdateUser(updated);
    _loadUser(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User account \'$username\' saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteUser() {
    if (_selectedUser == null || _selectedUser!.username == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master Admin account cannot be deleted.')),
      );
      return;
    }

    final deletedName = _selectedUser!.username;
    _auth.deleteUser(deletedName);
    _loadUser(_auth.allUsers.first);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User account \'$deletedName\' deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = _auth.allUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'User Access Control',
        subtitle: 'Account Credentials & 24+ Module Rights',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Select Account Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Account to Modify',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: _selectedUser?.username,
                    hint: const Text('-- Create New User --'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('+ Create New User Account',
                            style: TextStyle(color: Color(0xFF2F5D9F), fontWeight: FontWeight.bold)),
                      ),
                      ...allUsers.map((u) => DropdownMenuItem<String>(
                            value: u.username,
                            child: Text('${u.username} (${u.fullName}) - [${u.role}]'),
                          )),
                    ],
                    onChanged: (val) {
                      if (val == null) {
                        _clearFieldsForNewUser();
                      } else {
                        final u = allUsers.firstWhere((usr) => usr.username == val);
                        _loadUser(u);
                      }
                    },
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Credentials Form
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account Credentials & Role',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _usernameCtrl,
                    enabled: _selectedUser == null, // Lock username for existing
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _mobileCtrl,
                    decoration: const InputDecoration(labelText: 'Mobile Number'),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _selectedUser == null
                          ? 'New Password'
                          : 'Change Password (Leave blank to keep)',
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Role Designation:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'User', label: Text('User')),
                          ButtonSegment(value: 'Admin', label: Text('Admin')),
                        ],
                        selected: {_role},
                        onSelectionChanged: (val) =>
                            setState(() => _role = val.first),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Permission Toggles Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Module & Tab Access Permissions',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.science_rounded, size: 16),
                        label: const Text('R&D Access'),
                        onPressed: () => _openRndGranularSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade50,
                          foregroundColor: Colors.purple.shade800,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick Action Utility Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              for (var key in _permissions.keys) {
                                _permissions[key] = true;
                              }
                            });
                          },
                          child: const Text('Grant All'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              for (var key in _permissions.keys) {
                                _permissions[key] = false;
                              }
                            });
                          },
                          child: const Text('Revoke All'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _permissions = UserModel.defaultPermissions();
                            });
                          },
                          child: const Text('Default'),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  ..._moduleDefs.map((def) {
                    final key = def.key;
                    final label = def.value;
                    final isChecked = _permissions[key] ?? false;

                    return SwitchListTile(
                      title: Text(label, style: const TextStyle(fontSize: 13)),
                      value: isChecked,
                      onChanged: (val) {
                        setState(() => _permissions[key] = val);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _saveUser,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save User Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F5D9F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_selectedUser != null && _selectedUser!.username != 'admin')
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _deleteUser,
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openRndGranularSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final rndKeys = [
            'allow_rnd_pdlc',
            'allow_rnd_projects',
            'allow_rnd_sprints',
            'allow_rnd_hardware',
            'allow_rnd_components',
            'allow_rnd_risk',
            'allow_rnd_team',
            'allow_rnd_compliance',
            'allow_rnd_design_cad',
            'allow_rnd_prototyping_testing',
            'allow_rnd_bom',
            'allow_rnd_eco',
          ];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔬 R&D Granular Access Control Sheet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                Expanded(
                  child: ListView(
                    children: rndKeys.map((key) {
                      final isChecked = _permissions[key] ?? false;
                      return SwitchListTile(
                        title: Text(key.replaceAll('allow_rnd_', 'R&D ').toUpperCase(),
                            style: const TextStyle(fontSize: 12)),
                        value: isChecked,
                        onChanged: (val) {
                          setSheetState(() => _permissions[key] = val);
                          setState(() => _permissions[key] = val);
                        },
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F5D9F),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Apply R&D Rights'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

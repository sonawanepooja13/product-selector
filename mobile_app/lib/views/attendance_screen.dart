import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../services/biometric_sync_service.dart';
import 'widgets/attendance_card.dart';
import 'widgets/device_config_bottom_sheet.dart';
import 'widgets/metrics_overview.dart';
import 'widgets/record_detail_bottom_sheet.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final BiometricSyncService _syncService = BiometricSyncService();

  int _currentNavIndex = 0;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isConnecting = false;
  bool _isSyncing = false;
  String _connectionStatus = 'Biometric device offline';
  bool _isDeviceOnline = false;

  final TextEditingController _ipController =
      TextEditingController(text: '192.168.1.201');
  final TextEditingController _portController =
      TextEditingController(text: '4370');
  final TextEditingController _passwordController =
      TextEditingController(text: '0');

  late List<AttendanceRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = _syncService.getInitialRecords();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // ACTIONS
  // -------------------------------------------------------------------------

  Future<void> _testConnection() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showSnackBar('Please enter a valid Device IP address', isError: true);
      return;
    }

    setState(() => _isConnecting = true);

    try {
      await _syncService.testConnection(
        ip: ip,
        port: int.tryParse(_portController.text.trim()) ?? 4370,
        password: int.tryParse(_passwordController.text.trim()) ?? 0,
      );

      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isDeviceOnline = true;
        _connectionStatus = 'Connected to $ip:${_portController.text} (TCP)';
      });
      _showSnackBar('Device connected successfully via TCP/IP');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      _showSnackBar('Failed to connect: $e', isError: true);
    }
  }

  Future<void> _syncBiometricDevice() async {
    setState(() => _isSyncing = true);

    try {
      final newLogs = await _syncService.fetchNewLogs();

      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        _records.insertAll(0, newLogs);
      });

      _showSnackBar('Synced ${newLogs.length} new biometric record(s)');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      _showSnackBar('Sync failed: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : const Color(0xFF2F5D9F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<AttendanceRecord> get _filteredRecords {
    return _records.where((record) {
      final matchesSearch = record.employeeName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          record.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case 'Present':
          return record.status == AttendanceStatus.present;
        case 'Late':
          return record.status == AttendanceStatus.late;
        case 'Absent':
          return record.status == AttendanceStatus.absent;
        default:
          return true;
      }
    }).toList();
  }

  void _openConfigSheet() {
    DeviceConfigBottomSheet.show(
      context: context,
      ipController: _ipController,
      portController: _portController,
      passwordController: _passwordController,
      isConnecting: _isConnecting,
      onTestConnection: _testConnection,
      onSave: () => _showSnackBar('Device configuration saved'),
    );
  }

  // -------------------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Attendance Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Device Settings',
            icon: const Icon(Icons.settings_ethernet_rounded),
            onPressed: _openConfigSheet,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _records = _syncService.getInitialRecords());
              _showSnackBar('Attendance records refreshed');
            },
          ),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() => _records = _syncService.getInitialRecords());
          },
          child: Column(
            children: [
              _buildStatusBar(),
              MetricsOverview(records: _records),
              _buildSearchAndFilters(),
              Expanded(child: _buildAttendanceList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentNavIndex = idx);
          if (idx == 1) {
            _openConfigSheet();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.router_outlined),
            selectedIcon: Icon(Icons.router_rounded),
            label: 'Biometrics',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Reports',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSyncing ? null : _syncBiometricDevice,
        icon: _isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.sync_rounded),
        label: Text(_isSyncing ? 'Syncing...' : 'Sync Device'),
        backgroundColor: const Color(0xFF2F5D9F),
        foregroundColor: Colors.white,
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
              'Saark Operating System',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('Admin / HR Mobile Workspace'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.fingerprint_rounded,
                  size: 38, color: Color(0xFF2F5D9F)),
            ),
            decoration: BoxDecoration(
              color: Color(0xFF2F5D9F),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time_filled_rounded),
            title: const Text('Attendance & Biometrics'),
            selected: true,
            selectedColor: const Color(0xFF2F5D9F),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: const Text('Employee Directory'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: const Text('Leave Requests'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Payroll & Compensation'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Terminal Settings'),
            onTap: () {
              Navigator.pop(context);
              _openConfigSheet();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _isDeviceOnline ? Colors.green.shade50 : Colors.blueGrey.shade50,
      child: Row(
        children: [
          Icon(
            _isDeviceOnline
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            size: 18,
            color: _isDeviceOnline ? Colors.green.shade700 : Colors.blueGrey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _connectionStatus,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isDeviceOnline
                    ? Colors.green.shade900
                    : Colors.blueGrey.shade800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          SearchBar(
            hintText: 'Search employee name or ID...',
            leading: const Icon(Icons.search, size: 20),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Present', 'Late', 'Absent'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    selectedColor:
                        const Color(0xFF2F5D9F).withValues(alpha: 0.15),
                    checkmarkColor: const Color(0xFF2F5D9F),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF2F5D9F)
                          : Colors.grey.shade700,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    final list = _filteredRecords;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No attendance records found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = list[index];
        return AttendanceCard(
          item: item,
          onTap: () => RecordDetailBottomSheet.show(context, item),
        );
      },
    );
  }
}

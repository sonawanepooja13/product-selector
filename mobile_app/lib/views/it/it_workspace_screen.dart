import 'package:flutter/material.dart';
import '../widgets/mobile_header.dart';

class ItWorkspaceScreen extends StatelessWidget {
  const ItWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = [
      _ItAsset(
        tag: 'IT-LAP-042',
        name: 'Dell Latitude 5430 i7 16GB',
        assignedTo: 'Priya Sharma (R&D)',
        status: 'Active',
      ),
      _ItAsset(
        tag: 'IT-SRV-001',
        name: 'Saark Primary Local Database Server',
        assignedTo: 'IT Infrastructure',
        status: 'Online',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'IT Workspace Assets',
        subtitle: 'Hardware Inventory & Access Rights',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final a = assets[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.computer_rounded, color: Color(0xFF2F5D9F)),
              ),
              title: Text(a.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('Asset Tag: ${a.tag}\nAssigned: ${a.assignedTo}',
                  style: const TextStyle(fontSize: 12)),
              trailing: Chip(
                label: Text(a.status,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                backgroundColor: Colors.green.shade50,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ItAsset {
  final String tag;
  final String name;
  final String assignedTo;
  final String status;

  _ItAsset({
    required this.tag,
    required this.name,
    required this.assignedTo,
    required this.status,
  });
}

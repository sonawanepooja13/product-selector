import 'package:flutter/material.dart';
import '../widgets/mobile_header.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final machines = [
      _MachineItem(
        name: 'CNC Busbar Bending & Punching Machine',
        serial: 'CNC-2024-889',
        location: 'Shop Floor - Bay 2',
        status: 'Operational',
        nextService: '2026-09-25',
        color: Colors.green,
      ),
      _MachineItem(
        name: 'Sheet Metal Enclosure Welding Station',
        serial: 'WELD-2023-412',
        location: 'Shop Floor - Bay 1',
        status: 'Service Due',
        nextService: '2026-09-10',
        color: Colors.amber,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'Equipment Maintenance',
        subtitle: 'Factory Machinery Health & Service Schedule',
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: machines.length,
        itemBuilder: (context, index) {
          final m = machines[index];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(m.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      Chip(
                        label: Text(m.status,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold)),
                        backgroundColor: m.color.withOpacity(0.12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('S/N: ${m.serial} • Location: ${m.location}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text('Next Preventive Maintenance: ${m.nextService}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MachineItem {
  final String name;
  final String serial;
  final String location;
  final String status;
  final String nextService;
  final Color color;

  _MachineItem({
    required this.name,
    required this.serial,
    required this.location,
    required this.status,
    required this.nextService,
    required this.color,
  });
}

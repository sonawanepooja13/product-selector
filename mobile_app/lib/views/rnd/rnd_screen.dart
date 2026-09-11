import 'package:flutter/material.dart';
import '../../models/rnd_project.dart';
import '../../services/auth_service.dart';
import '../widgets/mobile_header.dart';

class RndScreen extends StatelessWidget {
  const RndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    // Removed 'const' keyword here
    final ecos = [
      EcoChangeOrder(
        ecoNumber: 'ECO-2026-001',
        title: 'Upgrade SMPS 24V 2.5A to Din-Rail 5A unit for HMI Stability',
        proposedBy: 'Priya Sharma (R&D Lead)',
        impactLevel: 'High Impact',
        status: EcoStatus.inReview,
        date: DateTime.utc(2026, 8, 20),
      ),
      EcoChangeOrder(
        ecoNumber: 'ECO-2026-002',
        title: 'Standardize RS485 Modbus Cable Gland Position on IP55 Door',
        proposedBy: 'Rajesh Kumar (Mfg)',
        impactLevel: 'Medium Impact',
        status: EcoStatus.approved,
        date: DateTime.utc(2026, 8, 24),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'R&D / Engineering',
        subtitle: 'PDLC Roadmap & ECO Change Orders',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // R&D Access Permission Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Color(0xFF9333EA)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'R&D Access Granted for ${user?.username ?? 'User'}. '
                    'Granular features enabled according to account rights.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9333EA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Engineering Change Orders (ECO)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...ecos.map((eco) => Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(eco.ecoNumber,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF9333EA))),
                          Chip(
                            label: Text(eco.statusLabel,
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                            backgroundColor: eco.status == EcoStatus.approved
                                ? Colors.green.shade50
                                : Colors.amber.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(eco.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        'Proposed by: ${eco.proposedBy} • ${eco.impactLevel}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
} 
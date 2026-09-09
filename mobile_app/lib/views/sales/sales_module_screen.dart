import 'package:flutter/material.dart';
import '../widgets/mobile_header.dart';
import 'price_lookup_view.dart';
import 'material_calculator_view.dart';
import 'crm_leads_view.dart';
import 'water_meter_view.dart';
import 'bms_selector_view.dart';

class SalesModuleScreen extends StatelessWidget {
  const SalesModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryOption(
        title: 'Customer CRM & Leads',
        subtitle: 'Lead directory, status pipeline & client follow-ups',
        icon: Icons.people_alt_rounded,
        color: const Color(0xFF2563EB),
        builder: (_) => const CrmLeadsView(),
      ),
      _CategoryOption(
        title: 'Booster Pump Control Panel',
        subtitle: 'HP selection, VFD config, BOM calculation & Net Quote',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF0284C7),
        builder: (_) => const PriceLookupView(category: 'Booster Pump Control Panel'),
      ),
      _CategoryOption(
        title: 'STP Panel (Sewage Treatment)',
        subtitle: 'Dual pump DOL/Star-Delta, timer & blower controls',
        icon: Icons.clean_hands_rounded,
        color: const Color(0xFF059669),
        builder: (_) => const PriceLookupView(category: 'STP Panel'),
      ),
      _CategoryOption(
        title: 'Water Meter & Smart Telemetry',
        subtitle: 'DN15-DN300 sizing, Flow rate Q3 & Modbus RS485',
        icon: Icons.speed_rounded,
        color: const Color(0xFFD97706),
        builder: (_) => const WaterMeterView(),
      ),
      _CategoryOption(
        title: 'BMS (Building Management)',
        subtitle: 'DDC controllers, I/O modules & BACnet/Modbus panels',
        icon: Icons.domain_rounded,
        color: const Color(0xFF7C3AED),
        builder: (_) => const BmsSelectorView(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'Sales & Marketing',
        subtitle: 'Product Category Selector',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Select Product Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...categories.map((cat) => _buildCategoryTile(context, cat)),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, _CategoryOption cat) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cat.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(cat.icon, color: cat.color, size: 28),
        ),
        title: Text(
          cat.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          cat.subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: cat.builder),
          );
        },
      ),
    );
  }
}

class _CategoryOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  _CategoryOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

import 'package:flutter/material.dart';
import '../../models/panel_spec.dart';
import '../widgets/mobile_header.dart';

class PanelMfgScreen extends StatefulWidget {
  const PanelMfgScreen({super.key});

  @override
  State<PanelMfgScreen> createState() => _PanelMfgScreenState();
}

class _PanelMfgScreenState extends State<PanelMfgScreen> {
  String _ipRating = 'IP55 Outdoor';
  String _sheetThickness = '2.0 mm Powder Coated';
  String _switchgearBrand = 'Schneider Electric';
  String _busbarMaterial = 'Electrolytic Copper';
  double _amps = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const MobileHeader(
        title: 'Panel Manufacturing',
        subtitle: 'Enclosures & Switchgear Specs',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Panel Job Card Specification',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                const Text(
                  'Heavy Industrial Control Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                Text('Rating: ${_amps.toInt()}A Amperes • Busbar: $_busbarMaterial',
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mechanical & Electrical Config',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _ipRating,
                    items: ['IP42 Indoor', 'IP54 Dustproof', 'IP55 Outdoor Weatherproof', 'IP65 Submersible']
                        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                        .toList(),
                    onChanged: (val) => setState(() => _ipRating = val!),
                    decoration: const InputDecoration(labelText: 'Ingress Protection (IP Rating)'),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _sheetThickness,
                    items: ['1.6 mm Cold Rolled', '2.0 mm Powder Coated', '2.5 mm Heavy Steel']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _sheetThickness = val!),
                    decoration: const InputDecoration(labelText: 'Sheet Enclosure Thickness'),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _switchgearBrand,
                    items: ['Schneider Electric', 'ABB', 'Siemens', 'L&T Switchgear']
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) => setState(() => _switchgearBrand = val!),
                    decoration: const InputDecoration(labelText: 'Switchgear Component Brand'),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _busbarMaterial,
                    items: ['Electrolytic Copper', 'Tinned Aluminum']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) => setState(() => _busbarMaterial = val!),
                    decoration: const InputDecoration(labelText: 'Busbar Conductor Material'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Panel Busbar Rating (${_amps.toInt()}A):'),
                      Chip(
                        label: Text('${_amps.toInt()} Amps'),
                        backgroundColor: Colors.purple.shade50,
                      ),
                    ],
                  ),
                  Slider(
                    value: _amps,
                    min: 25,
                    max: 800,
                    divisions: 31,
                    activeColor: const Color(0xFF7C3AED),
                    onChanged: (val) => setState(() => _amps = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

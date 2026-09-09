import 'package:flutter/material.dart';
import '../../models/crm_lead.dart';
import '../../services/crm_service.dart';
import '../widgets/mobile_header.dart';

class CrmLeadsView extends StatefulWidget {
  const CrmLeadsView({super.key});

  @override
  State<CrmLeadsView> createState() => _CrmLeadsViewState();
}

class _CrmLeadsViewState extends State<CrmLeadsView> {
  final CrmService _crmService = CrmService();
  LeadStage? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _crmService,
      builder: (context, _) {
        final leads = _crmService.leads.where((l) {
          if (_selectedFilter == null) return true;
          return l.stage == _selectedFilter;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: const MobileHeader(
            title: 'Customer CRM & Leads',
            subtitle: 'Pipeline & Inquiry Directory',
          ),
          body: Column(
            children: [
              // Pipeline Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F3B66),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Pipeline Value',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${_crmService.totalPipelineValue.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Chip(
                      avatar: const Icon(Icons.leaderboard_rounded,
                          color: Colors.white, size: 18),
                      label: Text('${_crmService.leads.length} Leads',
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.white24,
                    ),
                  ],
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Leads'),
                      selected: _selectedFilter == null,
                      onSelected: (_) => setState(() => _selectedFilter = null),
                    ),
                    const SizedBox(width: 8),
                    ...LeadStage.values.map((stage) {
                      final lead = CrmLead(
                        id: '',
                        clientName: '',
                        company: '',
                        phone: '',
                        email: '',
                        category: '',
                        estimatedValue: 0,
                        stage: stage,
                        notes: '',
                        createdAt: DateTime.now(),
                      );

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(lead.stageLabel),
                          selected: _selectedFilter == stage,
                          onSelected: (val) =>
                              setState(() => _selectedFilter = val ? stage : null),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Leads List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leads.length,
                  itemBuilder: (context, index) {
                    final item = leads[index];
                    return Card(
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
                                Expanded(
                                  child: Text(
                                    item.clientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                _buildStageBadge(item.stage),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.company} • ${item.category}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(item.phone,
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                Text(
                                  '₹${item.estimatedValue.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2F5D9F),
                                  ),
                                ),
                              ],
                            ),
                            if (item.notes.isNotEmpty) ...[
                              const Divider(height: 16),
                              Text(
                                item.notes,
                                style: const TextStyle(
                                    fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF2F5D9F),
            foregroundColor: Colors.white,
            onPressed: () => _showAddLeadDialog(context),
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Widget _buildStageBadge(LeadStage stage) {
    Color bg;
    Color fg;

    switch (stage) {
      case LeadStage.newLead:
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case LeadStage.inDiscussion:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade900;
        break;
      case LeadStage.quotationSent:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade700;
        break;
      case LeadStage.won:
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case LeadStage.lost:
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        break;
    }

    final lead = CrmLead(
      id: '',
      clientName: '',
      company: '',
      phone: '',
      email: '',
      category: '',
      estimatedValue: 0,
      stage: stage,
      notes: '',
      createdAt: DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        lead.stageLabel,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddLeadDialog(BuildContext context) {
    final clientCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String category = 'Booster Pump Control Panel';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Customer Lead',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: clientCtrl,
                decoration: const InputDecoration(labelText: 'Client Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(labelText: 'Company / Project'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Contact Phone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Estimated Value (₹)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                items: [
                  'Booster Pump Control Panel',
                  'STP Panel',
                  'Water Meter',
                  'BMS'
                ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => category = val!,
                decoration: const InputDecoration(labelText: 'Product Category'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Inquiry Notes'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5D9F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (clientCtrl.text.isNotEmpty) {
                      _crmService.addLead(
                        CrmLead(
                          id: 'LEAD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                          clientName: clientCtrl.text.trim(),
                          company: companyCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          email: 'contact@client.com',
                          category: category,
                          estimatedValue: double.tryParse(valCtrl.text) ?? 0.0,
                          stage: LeadStage.newLead,
                          notes: notesCtrl.text.trim(),
                          createdAt: DateTime.now(),
                        ),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save Lead'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

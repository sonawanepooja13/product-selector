import 'package:flutter/material.dart';
import '../../models/support_ticket.dart';
import '../../services/customer_service_api.dart';
import '../widgets/mobile_header.dart';

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({super.key});

  @override
  State<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  final CustomerServiceApi _service = CustomerServiceApi();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final tickets = _service.tickets;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: const MobileHeader(
            title: 'Customer Service Desk',
            subtitle: 'Support Tickets & Field Issues',
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final t = tickets[index];
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
                          Text(t.ticketId,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF4F46E5))),
                          Chip(
                            label: Text(t.priorityLabel,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            backgroundColor: t.priority == TicketPriority.urgent
                                ? Colors.red
                                : Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Client: ${t.customerName} • Serial: ${t.productSerial}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text(t.issueSummary,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      if (t.resolutionNotes.isNotEmpty) ...[
                        const Divider(height: 16),
                        Text('Resolution Notes: ${t.resolutionNotes}',
                            style: const TextStyle(
                                fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            onPressed: () => _showAddTicketDialog(context),
            child: const Icon(Icons.confirmation_number_rounded),
          ),
        );
      },
    );
  }

  void _showAddTicketDialog(BuildContext context) {
    final clientCtrl = TextEditingController();
    final serialCtrl = TextEditingController();
    final issueCtrl = TextEditingController();
    TicketPriority priority = TicketPriority.high;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
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
                const Text('Open New Support Ticket',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: clientCtrl,
                  decoration: const InputDecoration(labelText: 'Customer / Project Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: serialCtrl,
                  decoration: const InputDecoration(labelText: 'Product Serial Number'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: issueCtrl,
                  decoration: const InputDecoration(labelText: 'Issue Summary'),
                ),
                const SizedBox(height: 12),
                SegmentedButton<TicketPriority>(
                  segments: const [
                    ButtonSegment(
                        value: TicketPriority.urgent, label: Text('URGENT')),
                    ButtonSegment(
                        value: TicketPriority.high, label: Text('HIGH')),
                    ButtonSegment(
                        value: TicketPriority.medium, label: Text('MED')),
                  ],
                  selected: {priority},
                  onSelectionChanged: (val) =>
                      setModalState(() => priority = val.first),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (clientCtrl.text.isNotEmpty) {
                        _service.addTicket(
                          SupportTicket(
                            ticketId:
                                'TK-${(1000 + _service.tickets.length).toString()}',
                            customerName: clientCtrl.text.trim(),
                            productSerial: serialCtrl.text.trim(),
                            issueSummary: issueCtrl.text.trim(),
                            priority: priority,
                            status: TicketStatus.open,
                            createdAt: DateTime.now(),
                          ),
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Submit Support Ticket'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

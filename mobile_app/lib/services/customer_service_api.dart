import 'package:flutter/foundation.dart';
import '../models/support_ticket.dart';

class CustomerServiceApi extends ChangeNotifier {
  static final CustomerServiceApi _instance = CustomerServiceApi._internal();
  factory CustomerServiceApi() => _instance;

  CustomerServiceApi._internal() {
    _initTickets();
  }

  final List<SupportTicket> _tickets = [];
  List<SupportTicket> get tickets => List.unmodifiable(_tickets);

  void _initTickets() {
    _tickets.addAll([
      SupportTicket(
        ticketId: 'TK-1001',
        customerName: 'Metropolis Heights',
        productSerial: 'BP-2026-904',
        issueSummary: 'Pump 2 trips on VFD overload during peak hours',
        priority: TicketPriority.urgent,
        status: TicketStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        resolutionNotes: 'Dispatched field engineer to recalibrate VFD acceleration time.',
      ),
      SupportTicket(
        ticketId: 'TK-1002',
        customerName: 'Oceanic Towers',
        productSerial: 'WM-2026-112',
        issueSummary: 'Water Meter RS485 Modbus communication drop',
        priority: TicketPriority.medium,
        status: TicketStatus.open,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }

  void addTicket(SupportTicket ticket) {
    _tickets.insert(0, ticket);
    notifyListeners();
  }

  void updateTicketStatus(String ticketId, TicketStatus status, String notes) {
    final idx = _tickets.indexWhere((t) => t.ticketId == ticketId);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(
        status: status,
        resolutionNotes: notes,
      );
      notifyListeners();
    }
  }
}

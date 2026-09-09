enum TicketPriority { urgent, high, medium, low }
enum TicketStatus { open, inProgress, resolved }

class SupportTicket {
  final String ticketId;
  final String customerName;
  final String productSerial;
  final String issueSummary;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final String resolutionNotes;

  const SupportTicket({
    required this.ticketId,
    required this.customerName,
    required this.productSerial,
    required this.issueSummary,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.resolutionNotes = '',
  });

  String get priorityLabel {
    switch (priority) {
      case TicketPriority.urgent:
        return 'URGENT';
      case TicketPriority.high:
        return 'HIGH';
      case TicketPriority.medium:
        return 'MEDIUM';
      case TicketPriority.low:
        return 'LOW';
    }
  }

  String get statusLabel {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
    }
  }

  SupportTicket copyWith({
    String? ticketId,
    String? customerName,
    String? productSerial,
    String? issueSummary,
    TicketPriority? priority,
    TicketStatus? status,
    DateTime? createdAt,
    String? resolutionNotes,
  }) {
    return SupportTicket(
      ticketId: ticketId ?? this.ticketId,
      customerName: customerName ?? this.customerName,
      productSerial: productSerial ?? this.productSerial,
      issueSummary: issueSummary ?? this.issueSummary,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }
}

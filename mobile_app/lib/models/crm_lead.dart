enum LeadStage { newLead, inDiscussion, quotationSent, won, lost }

class CrmLead {
  final String id;
  final String clientName;
  final String company;
  final String phone;
  final String email;
  final String category; // Booster Pump, STP, Water Meter, BMS
  final double estimatedValue;
  final LeadStage stage;
  final String notes;
  final DateTime createdAt;

  const CrmLead({
    required this.id,
    required this.clientName,
    required this.company,
    required this.phone,
    required this.email,
    required this.category,
    required this.estimatedValue,
    required this.stage,
    required this.notes,
    required this.createdAt,
  });

  String get stageLabel {
    switch (stage) {
      case LeadStage.newLead:
        return 'New Lead';
      case LeadStage.inDiscussion:
        return 'In Discussion';
      case LeadStage.quotationSent:
        return 'Quotation Sent';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  CrmLead copyWith({
    String? id,
    String? clientName,
    String? company,
    String? phone,
    String? email,
    String? category,
    double? estimatedValue,
    LeadStage? stage,
    String? notes,
    DateTime? createdAt,
  }) {
    return CrmLead(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      stage: stage ?? this.stage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'company': company,
      'phone': phone,
      'email': email,
      'category': category,
      'estimated_value': estimatedValue,
      'stage': stage.toString().split('.').last,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CrmLead.fromJson(Map<String, dynamic> json) {
    LeadStage parseStage(String? s) {
      switch (s) {
        case 'newLead':
        case 'new_lead':
        case 'New Lead':
          return LeadStage.newLead;
        case 'inDiscussion':
        case 'in_discussion':
        case 'In Discussion':
          return LeadStage.inDiscussion;
        case 'quotationSent':
        case 'quotation_sent':
        case 'Quotation Sent':
          return LeadStage.quotationSent;
        case 'won':
        case 'Won':
          return LeadStage.won;
        case 'lost':
        case 'Lost':
          return LeadStage.lost;
        default:
          return LeadStage.newLead;
      }
    }

    return CrmLead(
      id: json['id']?.toString() ?? json['contact_id']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? json['primary_contact']?.toString() ?? '',
      company: json['company']?.toString() ?? json['company_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      estimatedValue: (json['estimated_value'] is num) ? (json['estimated_value'] as num).toDouble() : double.tryParse(json['estimated_value']?.toString() ?? '0') ?? 0.0,
      stage: parseStage(json['stage']?.toString()),
      notes: json['notes']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

import 'package:flutter/foundation.dart';
import '../models/crm_lead.dart';

class CrmService extends ChangeNotifier {
  static final CrmService _instance = CrmService._internal();
  factory CrmService() => _instance;

  CrmService._internal() {
    _initInitialLeads();
  }

  final List<CrmLead> _leads = [];
  List<CrmLead> get leads => List.unmodifiable(_leads);

  void _initInitialLeads() {
    _leads.addAll([
      CrmLead(
        id: 'LEAD-101',
        clientName: 'Apex Water Works',
        company: 'Apex Infrastructure Ltd',
        phone: '+91 98201 12345',
        email: 'purchase@apexinfra.com',
        category: 'Booster Pump Control Panel',
        estimatedValue: 145000,
        stage: LeadStage.inDiscussion,
        notes: 'Requested 3-Pump VFD Panel quote with RS485 telemetry.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CrmLead(
        id: 'LEAD-102',
        clientName: 'GreenTech STP Services',
        company: 'GreenTech Eco Solutions',
        phone: '+91 99870 54321',
        email: 'info@greentecheco.in',
        category: 'STP Panel',
        estimatedValue: 98000,
        stage: LeadStage.quotationSent,
        notes: 'Sent formal quotation Q-20260822-001. Awaiting PO.',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CrmLead(
        id: 'LEAD-103',
        clientName: 'BlueSky Residential Complex',
        company: 'BlueSky Realty Developers',
        phone: '+91 91234 88776',
        email: 'maintenance@bluesky.com',
        category: 'Water Meter',
        estimatedValue: 240000,
        stage: LeadStage.won,
        notes: 'Order confirmed for 50 Ultrasonic smart water meters.',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ]);
  }

  void addLead(CrmLead lead) {
    _leads.insert(0, lead);
    notifyListeners();
  }

  void updateLeadStage(String leadId, LeadStage newStage) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      _leads[idx] = _leads[idx].copyWith(stage: newStage);
      notifyListeners();
    }
  }

  double get totalPipelineValue =>
      _leads.fold(0.0, (sum, l) => sum + l.estimatedValue);
}

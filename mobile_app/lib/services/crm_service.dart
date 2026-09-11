import 'package:flutter/foundation.dart';
import '../models/crm_lead.dart';
import 'backend.dart';

class CrmService extends ChangeNotifier {
  static final CrmService _instance = CrmService._internal();
  factory CrmService() => _instance;

  CrmService._internal() {
    _initInitialLeads();
    _loadFromBackend();
    _subscribeToLiveEvents();
  }

  final List<CrmLead> _leads = [];
  List<CrmLead> get leads => List.unmodifiable(_leads);

  void _initInitialLeads() {
    _leads.addAll([
      CrmLead(
        id: '1',
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
        id: '2',
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
        id: '3',
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

  void _subscribeToLiveEvents() {
    BackendClient.addEventListener((event) {
      if (event['entity'] == 'crm') {
        _loadFromBackend();
      }
    });
  }

  void addLead(CrmLead lead) {
    _leads.insert(0, lead);
    notifyListeners();

    // Persist to centralized cloud API
    BackendClient.createContact(lead).then((resp) {
      final newId = resp['id']?.toString() ?? resp['contact_id']?.toString();
      if (newId != null && newId.isNotEmpty) {
        final idx = _leads.indexOf(lead);
        if (idx != -1) {
          _leads[idx] = lead.copyWith(id: newId);
          notifyListeners();
        }
      }
    }).catchError((_) {});
  }

  Future<void> _loadFromBackend() async {
    try {
      final backendLeads = await BackendClient.fetchContacts();
      if (backendLeads.isNotEmpty) {
        _leads.clear();
        _leads.addAll(backendLeads);
        notifyListeners();
      }
    } catch (_) {}
  }

  void updateLeadStage(String leadId, LeadStage newStage) {
    final idx = _leads.indexWhere((l) => l.id == leadId);
    if (idx != -1) {
      final updated = _leads[idx].copyWith(stage: newStage);
      _leads[idx] = updated;
      notifyListeners();

      final numId = int.tryParse(leadId);
      if (numId != null) {
        BackendClient.updateContact(numId, updated).catchError((_) => false);
      }
    }
  }

  void deleteLead(String leadId) {
    _leads.removeWhere((l) => l.id == leadId);
    notifyListeners();

    final numId = int.tryParse(leadId);
    if (numId != null) {
      BackendClient.deleteContact(numId).catchError((_) => false);
    }
  }

  double get totalPipelineValue =>
      _leads.fold(0.0, (sum, l) => sum + l.estimatedValue);
}

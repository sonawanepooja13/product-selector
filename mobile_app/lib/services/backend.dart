import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/crm_lead.dart';

class BackendClient {
  // Edit this to point to your deployed FastAPI backend (AWS EC2) when ready.
  static const String baseUrl = String.fromEnvironment('BACKEND_API_URL', defaultValue: 'http://127.0.0.1:8000');
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  static Future<List<CrmLead>> fetchContacts() async {
    final uri = Uri.parse('\$baseUrl/api/v1/crm/contacts');
    final resp = await http.get(uri, headers: _defaultHeaders).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data.map((e) => CrmLead.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch contacts: \\${resp.statusCode}');
  }

  static Future<Map<String, dynamic>> createContact(CrmLead lead) async {
    final uri = Uri.parse('\$baseUrl/api/v1/crm/contacts');
    final payload = {
      'company_name': lead.company,
      'primary_contact': lead.clientName,
      'email': lead.email,
      'phone': lead.phone,
      'status': lead.stage.toString().split('.').last,
      'estimated_value': lead.estimatedValue,
      'notes': lead.notes,
    };
    final resp = await http.post(uri, headers: _defaultHeaders, body: json.encode(payload)).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create contact: \\${resp.statusCode}');
  }

  // WebSocket support for CRM events (real-time updates)
  static WebSocketChannel? _wsChannel;

  static void connectCrmWebSocket(void Function(Map<String, dynamic>) onEvent) {
    if (_wsChannel != null) return;
    String wsUrl = baseUrl;
    if (wsUrl.startsWith('https://')) {
      wsUrl = wsUrl.replaceFirst('https://', 'wss://');
    } else if (wsUrl.startsWith('http://')) {
      wsUrl = wsUrl.replaceFirst('http://', 'ws://');
    }
    final uri = Uri.parse('\$wsUrl/ws/crm');
    try {
      _wsChannel = WebSocketChannel.connect(uri);
      _wsChannel!.stream.listen((message) {
        try {
          final data = json.decode(message) as Map<String, dynamic>;
          onEvent(data);
        } catch (_) {}
      }, onError: (_) {
        _wsChannel = null;
      }, onDone: () {
        _wsChannel = null;
      });
    } catch (_) {
      _wsChannel = null;
    }
  }

  static void disconnectCrmWebSocket() {
    try {
      _wsChannel?.sink.close();
    } catch (_) {}
    _wsChannel = null;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/crm_lead.dart';
import '../models/product_configuration.dart';

class BackendClient {
  // Configured via dart-define, or defaults to standard local dev / AWS IP
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static String? get authToken => _authToken;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null && _authToken!.isNotEmpty)
          'Authorization': 'Bearer $_authToken',
      };

  // ---------------------------------------------------------------------------
  // AUTHENTICATION
  // ---------------------------------------------------------------------------

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/login');
    final resp = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 8));

    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      _authToken = data['access_token']?.toString();
      return data;
    }
    throw Exception('Login failed: ${resp.body}');
  }

  // ---------------------------------------------------------------------------
  // PRODUCTS CRUD
  // ---------------------------------------------------------------------------

  static Future<List<ProductConfiguration>> fetchProducts(
      {String? category}) async {
    final query = category != null ? '?category=${Uri.encodeComponent(category)}' : '';
    final uri = Uri.parse('$baseUrl/api/v1/products$query');
    final resp = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data
          .map((e) => ProductConfiguration.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch products: ${resp.statusCode}');
  }

  static Future<ProductConfiguration> createProduct(
      ProductConfiguration product) async {
    final uri = Uri.parse('$baseUrl/api/v1/products');
    final resp = await http
        .post(uri, headers: _headers, body: json.encode(product.toJson()))
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return ProductConfiguration.fromJson(
          json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create product: ${resp.statusCode}');
  }

  static Future<ProductConfiguration> updateProduct(
      int id, ProductConfiguration product) async {
    final uri = Uri.parse('$baseUrl/api/v1/products/$id');
    final resp = await http
        .put(uri, headers: _headers, body: json.encode(product.toJson()))
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      return ProductConfiguration.fromJson(
          json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update product: ${resp.statusCode}');
  }

  static Future<bool> deleteProduct(int id) async {
    final uri = Uri.parse('$baseUrl/api/v1/products/$id');
    final resp = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 8));
    return resp.statusCode == 200;
  }

  // ---------------------------------------------------------------------------
  // CUSTOMERS CRUD
  // ---------------------------------------------------------------------------

  static Future<List<Customer>> fetchCustomers() async {
    final uri = Uri.parse('$baseUrl/api/v1/customers');
    final resp = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch customers: ${resp.statusCode}');
  }

  static Future<Customer> createCustomer(Customer customer) async {
    final uri = Uri.parse('$baseUrl/api/v1/customers');
    final resp = await http
        .post(uri, headers: _headers, body: json.encode(customer.toJson()))
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return Customer.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create customer: ${resp.statusCode}');
  }

  static Future<Customer> updateCustomer(int id, Customer customer) async {
    final uri = Uri.parse('$baseUrl/api/v1/customers/$id');
    final resp = await http
        .put(uri, headers: _headers, body: json.encode(customer.toJson()))
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      return Customer.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update customer: ${resp.statusCode}');
  }

  static Future<bool> deleteCustomer(int id) async {
    final uri = Uri.parse('$baseUrl/api/v1/customers/$id');
    final resp = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 8));
    return resp.statusCode == 200;
  }

  // ---------------------------------------------------------------------------
  // CRM CONTACTS / LEADS CRUD
  // ---------------------------------------------------------------------------

  static Future<List<CrmLead>> fetchContacts() async {
    final uri = Uri.parse('$baseUrl/api/v1/crm/contacts');
    final resp = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      return data
          .map((e) => CrmLead.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to fetch contacts: ${resp.statusCode}');
  }

  static Future<Map<String, dynamic>> createContact(CrmLead lead) async {
    final uri = Uri.parse('$baseUrl/api/v1/crm/contacts');
    final payload = {
      'company_name': lead.company,
      'primary_contact': lead.clientName,
      'email': lead.email,
      'phone': lead.phone,
      'status': lead.stage.toString().split('.').last,
      'category': lead.category,
      'estimated_value': lead.estimatedValue,
      'stage': lead.stage.toString().split('.').last,
      'notes': lead.notes,
    };
    final resp = await http
        .post(uri, headers: _headers, body: json.encode(payload))
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create contact: ${resp.statusCode}');
  }

  static Future<bool> updateContact(int id, CrmLead lead) async {
    final uri = Uri.parse('$baseUrl/api/v1/crm/contacts/$id');
    final payload = {
      'company_name': lead.company,
      'primary_contact': lead.clientName,
      'email': lead.email,
      'phone': lead.phone,
      'status': lead.stage.toString().split('.').last,
      'estimated_value': lead.estimatedValue,
      'stage': lead.stage.toString().split('.').last,
      'notes': lead.notes,
    };
    final resp = await http
        .put(uri, headers: _headers, body: json.encode(payload))
        .timeout(const Duration(seconds: 8));
    return resp.statusCode == 200;
  }

  static Future<bool> deleteContact(int id) async {
    final uri = Uri.parse('$baseUrl/api/v1/crm/contacts/$id');
    final resp = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 8));
    return resp.statusCode == 200;
  }

  // ---------------------------------------------------------------------------
  // REAL-TIME WEBSOCKET (BI-DIRECTIONAL SYNC)
  // ---------------------------------------------------------------------------

  static WebSocketChannel? _wsChannel;
  static final List<void Function(Map<String, dynamic>)> _eventListeners = [];

  static void addEventListener(void Function(Map<String, dynamic>) listener) {
    if (!_eventListeners.contains(listener)) {
      _eventListeners.add(listener);
    }
    connectWebSocket();
  }

  static void removeEventListener(void Function(Map<String, dynamic>) listener) {
    _eventListeners.remove(listener);
  }

  static void connectWebSocket() {
    if (_wsChannel != null) return;
    String wsUrl = baseUrl;
    if (wsUrl.startsWith('https://')) {
      wsUrl = wsUrl.replaceFirst('https://', 'wss://');
    } else if (wsUrl.startsWith('http://')) {
      wsUrl = wsUrl.replaceFirst('http://', 'ws://');
    }
    final uri = Uri.parse('$wsUrl/ws/events');
    try {
      _wsChannel = WebSocketChannel.connect(uri);
      _wsChannel!.stream.listen((message) {
        try {
          final data = json.decode(message) as Map<String, dynamic>;
          for (final listener in List.from(_eventListeners)) {
            try {
              listener(data);
            } catch (_) {}
          }
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

  static void disconnectWebSocket() {
    try {
      _wsChannel?.sink.close();
    } catch (_) {}
    _wsChannel = null;
  }
}

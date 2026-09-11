import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'backend.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    _initDefaultUsers();
  }

  UserModel? _currentUser;
  final List<UserModel> _users = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  List<UserModel> get allUsers => List.unmodifiable(_users);

  void _initDefaultUsers() {
    final adminPerms = UserModel.defaultPermissions();
    adminPerms.updateAll((key, val) => true);

    final adminUser = UserModel(
      username: 'admin',
      password: 'admin123',
      fullName: 'System Administrator',
      mobileNumber: '+91 9876543210',
      designation: 'Managing Director',
      role: 'Admin',
      permissions: adminPerms,
    );

    final userPerms = UserModel.defaultPermissions();
    userPerms['allow_price'] = true;
    userPerms['allow_material'] = true;
    userPerms['allow_sales'] = true;
    userPerms['allow_crm'] = true;

    final standardUser = UserModel(
      username: 'user',
      password: 'user123',
      fullName: 'Sales Executive',
      mobileNumber: '+91 9123456789',
      designation: 'Sales Representative',
      role: 'User',
      permissions: userPerms,
    );

    _users.clear();
    _users.addAll([adminUser, standardUser]);
  }

  Future<bool> loginAsync(String username, String password) async {
    try {
      final res = await BackendClient.login(username, password);
      final userData = res['user'] as Map<String, dynamic>;
      final rawPerms = (userData['permissions'] as Map<String, dynamic>?) ?? {};
      final perms = UserModel.defaultPermissions();
      rawPerms.forEach((k, v) {
        if (perms.containsKey(k)) {
          perms[k] = v == true;
        }
      });
      _currentUser = UserModel(
        username: userData['username']?.toString() ?? username,
        password: password,
        fullName: userData['full_name']?.toString() ?? '',
        mobileNumber: userData['mobile_number']?.toString() ?? '',
        designation: userData['designation']?.toString() ?? '',
        role: userData['role']?.toString() ?? 'User',
        permissions: perms,
      );
      notifyListeners();
      return true;
    } catch (_) {
      // Offline fallback
      return loginSync(username, password);
    }
  }

  bool login(String username, String password) {
    return loginSync(username, password);
  }

  bool loginSync(String username, String password) {
    try {
      final user = _users.firstWhere(
        (u) =>
            u.username.trim().toLowerCase() == username.trim().toLowerCase() &&
            u.password == password,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    BackendClient.setAuthToken(null);
    notifyListeners();
  }

  bool hasPermission(String permissionKey) {
    if (_currentUser == null) return false;
    return _currentUser!.hasPermission(permissionKey);
  }

  void addOrUpdateUser(UserModel updatedUser) {
    final idx = _users.indexWhere((u) => u.username == updatedUser.username);
    if (idx != -1) {
      _users[idx] = updatedUser;
      if (_currentUser?.username == updatedUser.username) {
        _currentUser = updatedUser;
      }
    } else {
      _users.add(updatedUser);
    }
    notifyListeners();
  }

  bool deleteUser(String username) {
    if (username == 'admin') return false;
    _users.removeWhere((u) => u.username == username);
    notifyListeners();
    return true;
  }
}

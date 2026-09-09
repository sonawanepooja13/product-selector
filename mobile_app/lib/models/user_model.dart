class UserModel {
  final String username;
  final String password;
  final String fullName;
  final String mobileNumber;
  final String designation;
  final String role; // "Admin", "User"
  final Map<String, bool> permissions;

  UserModel({
    required this.username,
    required this.password,
    required this.fullName,
    required this.mobileNumber,
    this.designation = '',
    this.role = 'User',
    Map<String, bool>? permissions,
  }) : permissions = permissions ?? defaultPermissions();

  static Map<String, bool> defaultPermissions() {
    return {
      'allow_price': true,
      'allow_material': true,
      'allow_crm': false,
      'allow_sales': false,
      'allow_production': false,
      'allow_project_management': false,
      'allow_qc_qa': false,
      'allow_panel_mfg': false,
      'allow_accounts': false,
      'allow_hr': false,
      'allow_attendance': false,
      'allow_purchase': false,
      'allow_stores': false,
      'allow_maintenance': false,
      'allow_rnd': false,
      'allow_asset_management': false,
      'allow_ehs': false,
      'allow_pos_ecommerce': false,
      'allow_it': false,
      'allow_customer_service': false,
      'allow_legal': false,
      'allow_admin_dept': false,
      'allow_supply_chain': false,
      'allow_admin': false,

      // Granular R&D
      'allow_rnd_pdlc': false,
      'allow_rnd_projects': false,
      'allow_rnd_sprints': false,
      'allow_rnd_hardware': false,
      'allow_rnd_components': false,
      'allow_rnd_risk': false,
      'allow_rnd_team': false,
      'allow_rnd_compliance': false,
      'allow_rnd_design_cad': false,
      'allow_rnd_prototyping_testing': false,
      'allow_rnd_bom': false,
      'allow_rnd_eco': false,
    };
  }

  bool get isAdmin => role == 'Admin';

  bool hasPermission(String key) {
    if (isAdmin) return true;
    return permissions[key] ?? false;
  }

  UserModel copyWith({
    String? username,
    String? password,
    String? fullName,
    String? mobileNumber,
    String? designation,
    String? role,
    Map<String, bool>? permissions,
  }) {
    return UserModel(
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      designation: designation ?? this.designation,
      role: role ?? this.role,
      permissions: permissions ?? Map.from(this.permissions),
    );
  }
}

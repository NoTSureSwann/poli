enum UserRole { admin, pasien, dokter, perawat, apoteker }

class User {
  final String id;
  final String nama;
  final String email;
  final UserRole role;
  final String? token; // Added to store the JWT session

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      token: json['token'],
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin': return UserRole.admin;
      case 'dokter': return UserRole.dokter;
      case 'perawat': return UserRole.perawat;
      case 'apoteker': return UserRole.apoteker;
      case 'pasien':
      default: return UserRole.pasien;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role.name,
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? nama,
    String? email,
    UserRole? role,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}

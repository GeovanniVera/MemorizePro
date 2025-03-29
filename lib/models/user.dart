class User {
  final String id;
  final String email;
  String password;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  // Método para convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

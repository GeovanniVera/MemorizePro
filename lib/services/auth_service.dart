import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  static User? _currentUser;
  static final List<User> _users = [];

  static User? get currentUser => _currentUser;
  // Método para registro seguro
  static Future<void> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email y contraseña son requeridos');
    }

    if (_userExists(email)) {
      throw Exception('El usuario ya existe');
    }

    final hashedPassword = _hashPassword(password);
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      password: hashedPassword,
      createdAt: DateTime.now(),
    );

    _users.add(user);
  }

  // Método para login
  static Future<User?> login(String email, String password) async {
  final user = _getUserByEmail(email);

  if (user != null && _verifyPassword(password, user.password)) {
    _currentUser = user; 
    return user;
  }
  return null;
}

  // Métodos auxiliares
  static bool _userExists(String email) =>
      _users.any((user) => user.email == email);

  static User? _getUserByEmail(String email) =>
      _users.firstWhere((user) => user.email == email);

  // Hashing de contraseña
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verificación de contraseña
  static bool _verifyPassword(String inputPassword, String storedHash) {
    return _hashPassword(inputPassword) == storedHash;
  }

  // Métodos adicionales
  static Future<void> updatePassword(String email, String newPassword) async {
    final user = _getUserByEmail(email);
    if (user != null) {
      user.password = _hashPassword(newPassword);
    }
  }

  static Future<void> deleteUser(String email) async {
    _users.removeWhere((user) => user.email == email);
  }

  // Método de logout
  static void logout() {
    _currentUser = null;
  }

  static List<User> get users => List.unmodifiable(_users);
}

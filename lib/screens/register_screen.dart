import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true; // Nuevo estado para confirmar contraseña

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registro exitoso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // AppBar vacío
      body: Center(
        // Centrado general
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centrado vertical
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título agregado
                  Text(
                    'Crear Cuenta',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 27, 67, 154),
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // Bloquea espacios
      ],
      decoration: InputDecoration(
        labelText: 'Correo Electrónico',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';

        if (trimmedValue.isEmpty) return 'Ingrese su correo electrónico';

        if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(trimmedValue)) {
          return 'Correo electrónico inválido';
        }

        final domain = trimmedValue.split('@').last.toLowerCase();
        if (domain != 'gmail.com' && domain != 'outlook.com') {
          return 'Solo se permiten correos de gmail.com o outlook.com';
        }

        return null;
      },
      onChanged: (value) {
        if (value.trim() != _emailController.text) {
          _emailController.text = value.trim();
          _emailController.selection = TextSelection.fromPosition(
            TextPosition(offset: _emailController.text.length),
          );
        }
      },
    );
  }

  Widget _buildPasswordField() {
  return TextFormField(
    controller: _passwordController,
    obscureText: _obscurePassword,
    inputFormatters: [
      FilteringTextInputFormatter.deny(RegExp(r'\s')) // Bloquea espacios
    ],
    decoration: InputDecoration(
      labelText: 'Contraseña',
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    validator: (value) {
      final trimmedValue = value?.trim() ?? '';
      
      if (trimmedValue.isEmpty) return 'Ingrese una contraseña';
      if (trimmedValue.length < 8) return 'Mínimo 8 caracteres';
      if (!trimmedValue.contains(RegExp(r'[A-Z]'))) return 'Al menos una mayúscula';
      if (!trimmedValue.contains(RegExp(r'[0-9]'))) return 'Al menos un número';
      
      return null;
    },
  );
}

Widget _buildConfirmPasswordField() {
  return TextFormField(
    controller: _confirmPasswordController,
    obscureText: _obscureConfirmPassword,
    inputFormatters: [
      FilteringTextInputFormatter.deny(RegExp(r'\s')) // Bloquea espacios
    ],
    decoration: InputDecoration(
      labelText: 'Confirmar Contraseña',
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    validator: (value) {
      final trimmedValue = value?.trim() ?? '';
      if (trimmedValue != _passwordController.text.trim()) {
        return 'Las contraseñas no coinciden';
      }
      return null;
    },
  );
}

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : _register,
        child:
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 27, 67, 154),
                  ),
                ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('¿Ya tienes cuenta?'),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Iniciar Sesión',
            style: TextStyle(color: Color.fromARGB(255, 27, 67, 154)),
          ),
        ),
      ],
    );
  }
}

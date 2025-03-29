import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 27, 42, 154), Color.fromARGB(255, 39, 82, 176), Color.fromARGB(255, 190, 219, 231)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Icon(Icons.quiz, size: 70, color: Color.fromARGB(255, 9, 29, 156)),
              ),
              SizedBox(height: 30),
              Text(
                'MemorizaPro',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Crea, memoriza y resuelve cuestionarios interactivos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 50),
              _buildActionButton(
                context: context,
                title: 'Iniciar Sesión',
                routeName: '/login',
                icon: Icons.login,
              ),
              SizedBox(height: 20),
              _buildActionButton(
                context: context,
                title: 'Registrarse',
                routeName: '/register',
                icon: Icons.person_add,
                isFilled: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String routeName,
    required IconData icon,
    bool isFilled = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFilled ? Colors.white : Colors.transparent,
          foregroundColor: isFilled ? Color.fromARGB(255, 27, 67, 154) : Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.white),
          ),
          elevation: 5,
        ),
        onPressed: () => Navigator.pushNamed(context, routeName),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

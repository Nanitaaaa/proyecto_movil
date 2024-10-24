import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:movil_app/services/google_service.dart';
import 'error_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  static final Logger _logger = Logger();
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 100.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Cambiado a start
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título estilizado
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Iniciar Sesión', // Título
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36, // Tamaño de fuente mayor
                    fontWeight: FontWeight.w700, // Negrita
                    color: Colors.blueAccent, // Color atractivo
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.grey,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), // Aumentar espacio entre el título y el siguiente texto
              const Text(
                'BIENVENIDO!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 100), // Espacio entre "Welcome Back!" y el botón
              ElevatedButton.icon(
                onPressed: () {
                  GoogleService.logIn().then((result) {
                    if (result) {
                      _logger.i('Login success');
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const HomeScreen();
                      }));
                    } else {
                      _logger.e('Login failed');
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const ErrorScreen();
                      }));
                    }
                  });
                },
                icon: const Icon(Icons.login, size: 24),
                label: const Text(
                  'Login with Google',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Acción para olvidar la contraseña o crear una cuenta
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

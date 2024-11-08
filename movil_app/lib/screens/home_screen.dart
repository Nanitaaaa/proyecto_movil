
import 'package:flutter/material.dart';
import 'package:movil_app/models/access.dart';
import 'package:movil_app/models/categories.dart';
import 'package:movil_app/models/tickets.dart'; // Asegúrate de importar el modelo Ticket;
import 'package:movil_app/services/rest_service.dart';
import 'package:logger/logger.dart';




class HomeScreen extends StatelessWidget {
  static final Logger _logger = Logger();

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {
                Future<List<Access>> future = RestServiceAccess.access();
                future.whenComplete(() {
                  _logger.i('Termine');
                });
              },
              child: const Text('Access'),
            ),
            const SizedBox(height: 20), // Espacio entre los botones
            FloatingActionButton(
              onPressed: () {
                Future<void> future = RestServiceTypes.access();
                future.whenComplete(() {
                  _logger.i('Termine');
                });
              },
              child: const Text('Types'),
            ),
            const SizedBox(height: 20), // Espacio entre los botones
            FloatingActionButton(
              onPressed: () {
                Future<List<Categories>> future = RestServiceCategories.access();
                future.whenComplete(() {
                  _logger.i('Termine');
                });
              },
              child: const Text('Categories'),
            ),
            const SizedBox(height: 20), // Espacio entre los botones
            FloatingActionButton(
              onPressed: () {
                Future<void> future = RestServiceStatus.access();
                future.whenComplete(() {
                  _logger.i('Termine');
                });
              },
              child: const Text('Status'),
            ),
            const SizedBox(height: 20), // Espacio entre los botones
            FloatingActionButton(
              onPressed: ()  {
                Future<List<Ticket>> future = RestServiceTickets.getAllTickets();
                future.whenComplete(() {
                  _logger.i('Termine');
                });
                
              },
              child: const Text('Tickets'),
            ),
          ],
        ),
      ),
    );
  }
}

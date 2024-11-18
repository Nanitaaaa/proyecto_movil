import 'package:flutter/material.dart';
import 'package:movil_app/screens/tickets_pending_screen.dart';
import 'package:movil_app/screens/tickets_progress_screen.dart';
import 'package:movil_app/screens/tickets_resolved_screen.dart';
import 'package:movil_app/screens/tickets_review_screen.dart';
import 'package:movil_app/screens/tickets_screen.dart'; // Asegúrate de que la importación sea correcta
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_app/screens/home_screen.dart';

class CustomScaffold extends StatefulWidget {
  final String title;
  final Widget body;

  const CustomScaffold({Key? key, required this.title, required this.body})
      : super(key: key);

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  String? userName;
  String? userEmail;
  String? userPhoto;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name');
      userEmail = prefs.getString('email');
      userPhoto = prefs.getString('image');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userName ?? 'Usuario desconocido',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(userEmail ?? 'Correo no disponible'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: userPhoto != null && userPhoto!.isNotEmpty
                    ? NetworkImage(userPhoto!)
                    : const AssetImage('assets/default_user.png')
                as ImageProvider,
                backgroundColor: Colors.grey.shade300,
              ),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_rounded),
              title: const Text('Ticket recibidos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TicketsScreen()
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded),
              title: const Text('Tickets bajo revisión'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TicketsReviewScreen()
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.running_with_errors_rounded ),
              title: const Text('Tickets en trabajo'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TicketsProgressScreen()
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search_off_rounded),
              title: const Text('Tickets incompletos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TicketsPendingScreen()
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.recommend),
              title: const Text('Tickets resueltos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TicketsResolvedScreen()
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                // Implementa el cierre de sesión
              },
            ),
          ],
        ),
      ),
      body: widget.body,
    );
  }
}

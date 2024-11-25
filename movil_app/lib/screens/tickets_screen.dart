import 'package:flutter/material.dart';
import 'package:movil_app/models/tickets.dart';
import 'package:movil_app/services/rest_service.dart';
import 'package:movil_app/screens/details_screen.dart';
import 'package:movil_app/shared/drawer.dart';
import 'package:logger/logger.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({Key? key}) : super(key: key);

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  static final Logger _logger = Logger();
  List<Ticket>? tickets;
  String? selectedType;
  bool _isLoading = false; // Estado para controlar la carga

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      tickets = await RestServiceTickets.getAllTickets('RECEIVED');
      _logger.i('Tickets cargados correctamente');
    } catch (error) {
      _logger.e('Error al cargar los tickets: $error');
    }

    setState(() {
      _isLoading = false; // Ocultar indicador de carga
    });
  }

  Color _getTicketColor(String type) {
    switch (type.toLowerCase()) {
      case 'claim':
        return Colors.redAccent.shade100;
      case 'information':
        return Colors.blueAccent.shade100;
      case 'suggestion':
        return Colors.greenAccent.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTickets = tickets?.where((ticket) {
      return selectedType == null || ticket.type.toLowerCase() == selectedType!.toLowerCase();
    }).toList();

    return CustomScaffold(
      title: 'Tickets Recibidos',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedType,
                hint: const Text('Filtrar por tipo', style: TextStyle(color: Colors.blueAccent)),
                dropdownColor: Colors.blue[50],
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue;
                  });
                },
                items: <String>['TODOS', 'claim', 'information', 'suggestion']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value == 'TODOS' ? null : value,
                    child: Text(
                      value == 'TODOS' ? 'Todos' : value.toUpperCase(),
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : tickets == null || filteredTickets?.isEmpty == true
                    ? const Center(
                  child: Text(
                    'No se encontraron tickets.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: filteredTickets?.length ?? 0,
                  itemBuilder: (context, index) {
                    final ticket = filteredTickets![index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TicketDetailScreen(ticket: ticket),
                          ),
                        );
                        if (result == true) {
                          _loadTickets(); // Recarga los tickets si el detalle indica cambios
                        }
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.subject,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTicketColor(ticket.type),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Text(
                                      ticket.type.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Text(
                                    'Estado: ${ticket.status}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                ticket.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

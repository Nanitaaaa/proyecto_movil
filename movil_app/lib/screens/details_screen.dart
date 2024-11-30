import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:movil_app/models/tickets.dart';
import 'package:movil_app/services/rest_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/attached.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  bool _isButtonDisabled = false;
  String? _selectedStatus;
  final TextEditingController _reasonController = TextEditingController();
  static final Logger _logger = Logger();

  bool hasAttachments() {
    return widget.ticket.attachedTokens.isNotEmpty;
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

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Future<void> _downloadFile(Attached attached) async {
    try {

      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) throw Exception('No se encontró el almacenamiento externo.');


      final downloadDir = Directory('${externalDir.parent.parent.parent.parent.path}/Download');
      final filePath = '${downloadDir.path}/${attached.name}';

      if (attached.data.contains(RegExp(r'^[A-Za-z0-9+/=]+$'))) {

        final decodedBytes = base64Decode(attached.data);
        final file = File(filePath);
        await file.writeAsBytes(decodedBytes);
        _logger.i('Archivo guardado en: $filePath ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo guardado en Descargas: $filePath')),
        );
      } else {
        final dio = Dio();
        final response = await dio.download(attached.data, filePath);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Archivo descargado: ${attached.name}')),
          );
        } else {
          throw Exception('Error al descargar el archivo desde la URL.');
        }
      }
    } catch (e) {
      debugPrint('Error al descargar el archivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el archivo: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateTicketStatus(
      BuildContext context, String newStatus, String successMessage) async {
    setState(() {
      _isButtonDisabled = true;
    });

    final success = await TicketStateManager.updateTicketStatus(
      ticketToken: widget.ticket.token,
      newStatus: newStatus,
      responseMessage: _reasonController.text.isNotEmpty
          ? _reasonController.text
          : successMessage,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
      setState(() {
        widget.ticket.status = newStatus;
        _isButtonDisabled = false;
        _selectedStatus = null;
        _reasonController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar el estado del ticket")),
      );
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: const Text(
          'Detalles del Ticket',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información del Ticket
            Card(
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
                    // Asunto
                    Text(
                      widget.ticket.subject,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Tipo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: _getTicketColor(widget.ticket.type),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        widget.ticket.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Estado
                    Text(
                      'Estado: ${widget.ticket.status}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Categoría
                    const Text(
                      'Categoría:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.ticket.category.name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Mensaje
                    const Text(
                      'Mensaje:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.ticket.message,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Respuesta
                    const Text(
                      'Respuesta:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.ticket.response.isNotEmpty
                          ? widget.ticket.response
                          : 'Sin respuesta todavía.',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // Fechas
                    const Text(
                      'Fecha de creación:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      formatDate(widget.ticket.created),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Fecha de actualización:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      formatDate(widget.ticket.updated),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const SizedBox(height: 20.0),
                    if (hasAttachments())
                      const Text(
                        'Archivos Adjuntos:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.ticket.attachedTokens.length,
                      itemBuilder: (context, index) {
                        final attToken = widget.ticket.attachedTokens[index];
                        return FutureBuilder(
                          future: RestServiceAttached.getTicketAttached(
                            ticketToken: widget.ticket.token,
                            attToken: attToken,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const ListTile(
                                title: Text('Cargando archivo...'),
                                leading: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return const ListTile(
                                title: Text('Error al cargar el archivo.'),
                                leading: Icon(Icons.error, color: Colors.red),
                              );
                            } else if (snapshot.hasData && snapshot.data is Attached) {
                              final attached = snapshot.data as Attached;
                              return ListTile(
                                leading: const Icon(Icons.attachment, color: Colors.blueAccent),
                                title: Text(attached.name),
                                trailing: IconButton(
                                  icon: const Icon(Icons.download, color: Colors.green),
                                  onPressed: () async {
                                    await _downloadFile(attached);
                                  },
                                ),
                              );
                            }
                            else {
                              return const ListTile(
                                title: Text('Archivo no disponible'),
                                leading: Icon(Icons.warning, color: Colors.orange),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Botones según el estado
            if (widget.ticket.status == 'RECEIVED') ...[
              Text(
                "Al presionar este botón, el estado se cambiará a 'En Revisión'.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: _isButtonDisabled
                    ? null
                    : () async {
                  await _updateTicketStatus(
                    context,
                    'UNDER_REVIEW',
                    'El ticket ahora está en revisión.',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Mover a Revisión',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],

            if (widget.ticket.status == 'UNDER_REVIEW') ...[
              Text(
                "Al presionar este botón, el estado se actualizará a 'Trabajando en ello'.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: _isButtonDisabled
                    ? null
                    : () async {
                  await _updateTicketStatus(
                    context,
                    'IN_PROGRESS',
                    'El ticket está en proceso.',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
                child: const Text(
                  'Mover a En Proceso',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],

            if (widget.ticket.status == 'IN_PROGRESS') ...[
              DropdownButton<String>(
                value: _selectedStatus,
                hint: const Text("Seleccionar nuevo estado"),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'RESOLVED',
                    child: Text('Resuelto'),
                  ),
                  DropdownMenuItem(
                    value: 'PENDING_INFORMATION',
                    child: Text('Pendiente de Información'),
                  ),
                ],
              ),
              if (_selectedStatus == 'PENDING_INFORMATION') ...[
                const SizedBox(height: 10.0),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Razón',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isButtonDisabled || _selectedStatus == null
                    ? null
                    : () {
                  if (_selectedStatus == 'PENDING_INFORMATION' &&
                      _reasonController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Por favor, ingrese una razón."),
                      ),
                    );
                    return;
                  }
                  _updateTicketStatus(
                    context,
                    _selectedStatus!,
                    'El ticket ha sido resuelto exitosamente.',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                ),
                child: const Text(
                  'Actualizar Estado',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            if (widget.ticket.status == 'PENDING_INFORMATION') ...[
              Text(
                "Al ticket le falta información para completar.",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (widget.ticket.status == 'RESOLVED') ...[
              Text(
                "El ticket ya esta resuelto.",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

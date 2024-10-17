import 'package:fcccontrolcenter/data/help.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:fcccontrolcenter/services/help_service.dart';
import 'package:mime/mime.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// `AyudasPopup`: Un widget de diálogo que permite la visualización y gestión de solicitudes de ayuda.
///
/// Este widget permite mostrar una lista de solicitudes de ayuda desde la base de datos, filtrar las solicitudes por su estado, y ver los detalles de cada solicitud.
/// Los detalles incluyen información como el mensaje, la fecha, y la posibilidad de descargar y visualizar archivos adjuntos.
class AyudasPopup extends StatefulWidget {
  final DBService dbService; // Servicio de base de datos
  final StorageService storageService; // Servicio de almacenamiento

  const AyudasPopup({
    super.key,
    required this.dbService,
    required this.storageService,
  });

  @override
  _AyudasPopupState createState() => _AyudasPopupState();
}

class _AyudasPopupState extends State<AyudasPopup>
    with SingleTickerProviderStateMixin {
  List<HelpVar> helps = [];
  List<HelpVar> filteredHelps = [];
  TabController? _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchHelps(); // Obtiene las solicitudes de ayuda al iniciar el widget.
    _tabController = TabController(length: 4, vsync: this); // Configura las pestañas.
  }

  /// Obtiene todas las solicitudes de ayuda de la base de datos e inicializa las listas.
  Future<void> _fetchHelps() async {
    try {
      final allHelps = await HelpService.getAllHelps(
        dbService: widget.dbService,
      );
      setState(() {
        helps = allHelps ?? []; // Inicializa la lista de ayudas.
        filteredHelps = helps;  // Inicializa la lista filtrada con todas las ayudas.
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching helps: $e');
      }
    }
  }

  /// Filtra las ayudas en función de la consulta de búsqueda.
  void _filterHelps(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredHelps = helps;
      } else {
        filteredHelps = helps
            .where((help) => help.id != null && help.id!.contains(query))
            .toList();
      }
    });
  }

  /// Actualiza el estado de una solicitud de ayuda.
  Future<void> _updateHelpStatus(String id, String status) async {
    try {
      await HelpService.updateHelpStatus(
        dbService: widget.dbService,
        helpId: id,
        newStatus: status,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating help status: $e');
      }
    }
  }

  /// Obtiene los datos de un archivo desde el almacenamiento.
  Future<Uint8List?> _getFileData(String? fileName) async {
    if (fileName == null) {
      if (kDebugMode) {
        print('File name is null');
      }
      return null;
    }

    try {
      final fileData = await widget.storageService.getFileFromST(
        path: 'helps',
        data: fileName,
      );
      return fileData;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving file data: $e');
      }
      return null;
    }
  }

  /// Descarga un archivo al almacenamiento local.
  Future<void> _downloadFile(String fileName, Uint8List fileData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    try {
      await file.writeAsBytes(fileData);
      if (kDebugMode) {
        print('File saved at ${file.path}');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo descargado en ${file.path}')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving file: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al descargar el archivo')),
      );
    }
  }

  /// Muestra los detalles completos de una solicitud de ayuda.
  void _showHelpDetails(HelpVar help) async {
    final fileData = await _getFileData(help.file);
    final mimeType = lookupMimeType(help.file ?? '', headerBytes: fileData) ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de Ayuda: ${help.id ?? "N/A"}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Email: ${help.email ?? "N/A"}'),
                Text('Tipo de Ayuda: ${help.helpType?.displayName ?? "N/A"}'),
                Text('Mensaje: ${help.message ?? "N/A"}'),
                Text('Fecha: ${help.time ?? "N/A"}'),
                const SizedBox(height: 10),
                _buildFilePreview(mimeType, fileData),
              ],
            ),
          ),
          actions: <Widget>[
            if (fileData != null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                ),
                child: const Text('Descargar'),
                onPressed: () async {
                  if (help.file != null) {
                    await _downloadFile(help.file!, fileData);
                  }
                },
              ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green,
              ),
              child: const Text('Aceptar'),
              onPressed: () {
                if (help.id != null) {
                  _updateHelpStatus(help.id!, '2'); // Actualiza el estado a 'Aceptado'.
                }
                Navigator.of(context).pop();
                _fetchHelps(); // Refresca la lista después de actualizar el estado.
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red,
              ),
              child: const Text('Rechazar'),
              onPressed: () {
                if (help.id != null) {
                  _updateHelpStatus(help.id!, '3'); // Actualiza el estado a 'Rechazado'.
                }
                Navigator.of(context).pop();
                _fetchHelps(); // Refresca la lista después de actualizar el estado.
              },
            ),
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () async {
                if (help.status == '0' && help.id != null) {
                  await _updateHelpStatus(help.id!, '1').then((_) {
                    Navigator.of(context).pop();
                    _fetchHelps(); // Refresca la lista si el estado cambia de 0 a 1.
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Construye una vista previa del archivo adjunto.
  Widget _buildFilePreview(String mimeType, Uint8List? fileData) {
    if (fileData == null) {
      return const Text('Archivo no disponible');
    }

    if (mimeType.startsWith('image/')) {
      return Image.memory(fileData, fit: BoxFit.contain);
    } else if (mimeType == 'application/pdf') {
      final pdfController = PdfController(
        document: PdfDocument.openData(fileData),
      );
      return SizedBox(
        width: 300,
        height: 400,
        child: PdfView(
          controller: pdfController,
        ),
      );
    } else {
      return const Text('No se puede mostrar el archivo o no hay archivo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Recibido'),
                Tab(text: 'En Proceso'),
                Tab(text: 'Completado'),
                Tab(text: 'Rechazado'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar por ID',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterHelps(value); // Filtra las ayudas basadas en la consulta de búsqueda.
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHelpList(0), // Solicitudes recibidas
                  _buildHelpList(1), // Solicitudes en proceso
                  _buildHelpList(2), // Solicitudes completadas
                  _buildHelpList(3), // Solicitudes rechazadas
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una lista de ayudas según el estado dado.
  Widget _buildHelpList(int status) {
    if (filteredHelps.isEmpty) {
      return const Center(child: Text('No hay ayudas disponibles.'));
    }

    List<HelpVar> helpsByStatus = filteredHelps
        .where((help) => help.status == status.toString())
        .toList();

    if (helpsByStatus.isEmpty) {
      return const Center(child: Text('No hay ayudas en esta categoría.'));
    }

    return ListView.builder(
      itemCount: helpsByStatus.length,
      itemBuilder: (context, index) {
        final help = helpsByStatus[index];

        return ListTile(
          title: Text('ID: ${help.id ?? "N/A"}'),
          subtitle: Text('Tipo de Ayuda: ${help.helpType?.displayName ?? "N/A"}'),
          onTap: () {
            _showHelpDetails(help); // Muestra los detalles de la ayuda al hacer clic.
          },
        );
      },
    );
  }
}

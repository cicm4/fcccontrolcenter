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

class AyudasPopup extends StatefulWidget {
  final DBService dbService;
  final StorageService storageService;

  const AyudasPopup({
    Key? key,
    required this.dbService,
    required this.storageService,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
    _fetchHelps();
    _tabController = TabController(length: 4, vsync: this);
  }

  /// Fetches all helps from the database and initializes the lists.
  Future<void> _fetchHelps() async {
    try {
      final allHelps = await HelpService.getAllHelps(
        dbService: widget.dbService,
      );
      setState(() {
        helps = allHelps ?? []; // Initialize helps list
        filteredHelps = helps; // Initialize filteredHelps with helps
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching helps: $e');
      }
    }
  }

  /// Filters helps based on the search query.
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

  /// Updates the status of a help request.
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

  /// Retrieves the file from storage and returns the file data.
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

  /// Downloads the file to the local storage.
  Future<void> _downloadFile(String fileName, Uint8List fileData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    try {
      await file.writeAsBytes(fileData);
      if (kDebugMode) {
        print('File saved at ${file.path}');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo descargado en ${file.path}')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving file: $e');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al descargar el archivo')),
      );
    }
  }

  /// Displays detailed information about a help request.
  void _showHelpDetails(HelpVar help) async {
    final fileData = await _getFileData(help.file);
    final mimeType = lookupMimeType(help.file ?? '', headerBytes: fileData) ?? '';

    // ignore: use_build_context_synchronously
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
                  _updateHelpStatus(help.id!, '2');
                }
                Navigator.of(context).pop();
                _fetchHelps(); // Refresh list after status update
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red,
              ),
              child: const Text('Rechazar'),
              onPressed: () {
                if (help.id != null) {
                  _updateHelpStatus(help.id!, '3');
                }
                Navigator.of(context).pop();
                _fetchHelps(); // Refresh list after status update
              },
            ),
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () async {
                // Check and update status from 0 to 1 if necessary
                if (help.status == '0' && help.id != null) {
                  await _updateHelpStatus(help.id!, '1').then((_) {
                    Navigator.of(context).pop();
                    _fetchHelps(); // Refresh list after status update
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

  /// Builds a preview for the attached file.
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
                    _filterHelps(value);
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHelpList(0), // Received
                  _buildHelpList(1), // In Process
                  _buildHelpList(2), // Completed
                  _buildHelpList(3), // Rejected
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a list of helps for a given status.
  Widget _buildHelpList(int status) {
    // Ensure filteredHelps is not null before proceeding
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
            _showHelpDetails(help);
          },
        );
      },
    );
  }
}

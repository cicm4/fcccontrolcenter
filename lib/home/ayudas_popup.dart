import 'package:fcccontrolcenter/data/help.dart';
import 'package:fcccontrolcenter/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fcccontrolcenter/services/database_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:fcccontrolcenter/services/help_service.dart';
import 'package:path_provider/path_provider.dart';

class AyudasPopup extends StatefulWidget {
  final DBService dbService;
  final StorageService storageService;

  const AyudasPopup({
    Key? key,
    required this.dbService,
    required this.storageService,
  }) : super(key: key);

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
    _fetchHelps();
    _tabController = TabController(length: 4, vsync: this);
  }

  /// Fetches all helps from the database and initializes the lists.
  Future<void> _fetchHelps() async {
    final allHelps = await HelpService.getAllHelps(
      dbService: widget.dbService, userService: UserService(),
    );
    setState(() {
      helps = allHelps ?? []; // Initialize helps list
      filteredHelps = helps; // Initialize filteredHelps with helps
    });
  }

  /// Filters helps based on the search query.
  void _filterHelps(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredHelps = helps;
      });
    } else {
      setState(() {
        filteredHelps = helps
            .where((help) => help.id != null && help.id!.contains(query))
            .toList();
      });
    }
  }

  /// Updates the status of a help request.
  Future<void> _updateHelpStatus(String id, String status) async {
    try {
      await HelpService.updateHelpStatus(
        dbService: widget.dbService,
        helpId: id,
        newStatus: status,
      );
      _fetchHelps();
    } catch (e) {
      print('Error updating help status: $e');
    }
  }

  /// Downloads the attached file of a help request.
  Future<void> _downloadFile(String fileName, String helpId) async {
    final fileUrl = await HelpService.getFileDownloadURL(
      storageService: widget.storageService,
      helpId: helpId,
      fileName: fileName,
    );

    if (fileUrl != null) {
      final downloadDir = await getDownloadsDirectory();
      if (downloadDir != null) {
        final savePath = '${downloadDir.path}/$fileName';

        await HelpService.downloadFile(url: fileUrl, savePath: savePath);
      }
    }
  }

  /// Displays detailed information about a help request.
  void _showHelpDetails(HelpVar help) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de Ayuda: ${help.id ?? "N/A"}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Email: ${help.email ?? "N/A"}'),
                Text('Tipo de Ayuda: ${help.helpType ?? "N/A"}'),
                Text('Mensaje: ${help.message ?? "N/A"}'),
                Text('Fecha: ${help.time ?? "N/A"}'),
                ElevatedButton(
                  onPressed: () {
                    if (help.id != null) {
                      _downloadFile('${help.id}.pdf', help.id!);
                    }
                  },
                  child: const Text('Descargar Archivo Adjunto'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                if (help.id != null) {
                  _updateHelpStatus(help.id!, '2');
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Rechazar'),
              onPressed: () {
                if (help.id != null) {
                  _updateHelpStatus(help.id!, '3');
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          subtitle: Text('Tipo de Ayuda: ${help.helpType ?? "N/A"}'),
          onTap: () {
            if (status == 0 && help.id != null) {
              _updateHelpStatus(help.id!, '1'); // Mark as seen (In Process)
            }
            _showHelpDetails(help);
          },
        );
      },
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fcccontrolcenter/services/scholarship_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:pdfx/pdfx.dart';
import 'package:mime/mime.dart';
import 'dart:typed_data';

/// Widget `ScholarshipPopup`
/// 
/// Este cuadro de diálogo muestra la información de la beca para un usuario específico. 
/// Permite visualizar la información de la cuenta bancaria, cédula y archivos adjuntos relacionados 
/// (como liquidación de matrícula, horario, y soporte de pago). Además, incluye opciones para 
/// descargar o eliminar estos archivos.
class ScholarshipPopup extends StatefulWidget {
  final Map<String, dynamic> scholarshipData; // Datos de la beca del usuario
  final Future<void> Function(String) removeFile; // Función para eliminar un archivo
  final Future<void> Function(String) downloadFile; // Función para descargar un archivo
  final ScholarshipService scholarshipService; // Servicio para obtener información de la beca
  final StorageService storageService; // Servicio de almacenamiento
  final String name; // Nombre del usuario

  const ScholarshipPopup({
    super.key,
    required this.scholarshipData,
    required this.removeFile,
    required this.downloadFile,
    required this.scholarshipService,
    required this.storageService,
    required this.name,
  });

  @override
  _ScholarshipPopupState createState() => _ScholarshipPopupState();
}

class _ScholarshipPopupState extends State<ScholarshipPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Información de Beca para ${widget.name}'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            // Muestra la información de la cuenta bancaria si está disponible
            if (!widget.scholarshipData['isBankDataFile']) ...[
              Text(
                'Número de Cuenta Bancaria: ${widget.scholarshipData['bankaccount']}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ] else ...[
              _buildFileItem('Cuenta Bancaria', UrlFileType.bankaccount),
            ],
            Text('Cédula: ${widget.scholarshipData['gid']}'),
            const SizedBox(height: 10),
            // Muestra la información de los archivos adjuntos de la beca
            _buildFileItem('Liquidación de Matrícula', UrlFileType.matriculaURL),
            const SizedBox(height: 10),
            _buildFileItem('Horario', UrlFileType.horarioURL),
            const SizedBox(height: 10),
            _buildFileItem('Soporte de Pago', UrlFileType.soporteURL),
            const SizedBox(height: 10),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el cuadro de diálogo
          },
        ),
      ],
    );
  }

  /// Construye un widget que representa un archivo asociado a la beca.
  ///
  /// @param title Título del archivo que se mostrará.
  /// @param fileType Tipo del archivo (por ejemplo, liquidación de matrícula, horario, etc.).
  Widget _buildFileItem(String title, UrlFileType fileType) {
    final screenSize = MediaQuery.of(context).size;
    final sizeBasedOnScreenSize = screenSize.width * 0.1;

    return FutureBuilder<Uint8List?>(
      future: widget.scholarshipService.getURLFile(
        fileType: fileType,
        storageService: widget.storageService,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Indicador de carga basado en el tamaño de la pantalla
          return SizedBox(
            height: sizeBasedOnScreenSize,
            width: sizeBasedOnScreenSize / 3,
            child: const CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Text('Error al cargar el archivo');
        } else if (snapshot.data == null) {
          return const Text('Archivo no disponible');
        } else {
          Uint8List? data = snapshot.data;
          String mimeType = lookupMimeType('', headerBytes: data) ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              _buildFilePreviewContainer(mimeType, data!),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => widget.downloadFile(fileType.toString().split('.').last),
                    child: const Text('Descargar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => widget.removeFile(fileType.toString().split('.').last),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        }
      },
    );
  }

  /// Construye una vista previa del archivo.
  ///
  /// @param mimeType Tipo MIME del archivo para determinar cómo mostrarlo. (pdf, imagen, etc.)
  /// @param data Contenido del archivo en formato `Uint8List`.
  Widget _buildFilePreviewContainer(String mimeType, Uint8List data) {
    double maxWidth = 800;
    double maxHeight = 1250;

    if (mimeType.startsWith('image/')) {
      Image image = Image.memory(data, fit: BoxFit.contain);
      return FutureBuilder<ImageInfo>(
        future: _getImageInfo(image),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            double imageWidth = snapshot.data!.image.width.toDouble();
            double imageHeight = snapshot.data!.image.height.toDouble();

            double scaleWidth = maxWidth / imageWidth;
            double scaleHeight = maxHeight / imageHeight;
            double scale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

            double containerWidth = imageWidth * scale;
            double containerHeight = imageHeight * scale;

            return Center(
              child: SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: image,
                ),
              ),
            );
          } else {
            return SizedBox(
              width: maxWidth,
              height: maxHeight,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      );
    } else if (mimeType == 'application/pdf') {
      final pdfController = PdfController(
        document: PdfDocument.openData(data),
      );
      return SizedBox(
        width: maxWidth,
        height: maxHeight,
        child: PdfView(
          controller: pdfController,
        ),
      );
    } else {
      return const Text('No se puede mostrar el archivo o no hay archivo');
    }
  }

  /// Obtiene la información de la imagen.
  Future<ImageInfo> _getImageInfo(Image image) async {
    Completer<ImageInfo> completer = Completer();
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info);
      }),
    );
    return completer.future;
  }
}

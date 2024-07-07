import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fcccontrolcenter/services/scholarship_service.dart';
import 'package:fcccontrolcenter/services/storage_service.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mime/mime.dart';
import 'dart:typed_data';

class ScholarshipPopup extends StatefulWidget {
  final Map<String, dynamic> scholarshipData;
  final Future<void> Function(String) removeFile;
  final Future<void> Function(String) downloadFile;
  final ScholarshipService scholarshipService;
  final StorageService storageService;

  const ScholarshipPopup({
    Key? key,
    required this.scholarshipData,
    required this.removeFile,
    required this.downloadFile,
    required this.scholarshipService,
    required this.storageService,
  }) : super(key: key);

  @override
  _ScholarshipPopupState createState() => _ScholarshipPopupState();
}

class _ScholarshipPopupState extends State<ScholarshipPopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Información de Beca para ${widget.scholarshipData['uid']}'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            if (!widget.scholarshipData['isBankDataFile']) ...[
              Text('Número de Cuenta Bancaria: ${widget.scholarshipData['bankaccount']}', style: const TextStyle(fontWeight: FontWeight.w700),),
            ] else ...[
              _buildFileItem('Cuenta Bancaria', UrlFileType.bankaccount),
            ],
            Text('Cedula: ${widget.scholarshipData['gid']}'),
            const SizedBox(height: 10),
            _buildFileItem('Liquidación de Matrícula', UrlFileType.matriculaURL),
            _buildFileItem('Horario', UrlFileType.horarioURL),
            _buildFileItem('Soporte de Pago', UrlFileType.soporteURL),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildFileItem(String title, UrlFileType fileType) {
    return FutureBuilder<Uint8List?>(
      future: widget.scholarshipService.getURLFile(
        fileType: fileType,
        storageService: widget.storageService,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
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
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => widget.downloadFile(fileType.toString().split('.').last),
                    child: const Text('Descargar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => widget.removeFile(fileType.toString().split('.').last),
                    child: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
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
              child: Container(
                width: containerWidth,
                height: containerHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: image,
                ),
              ),
            );
          } else {
            return Container(
              width: maxWidth,
              height: maxHeight,
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      );
    } else if (mimeType == 'application/pdf') {
      return Container(
        width: maxWidth,
        height: maxHeight,
        child: PDFView(
          pdfData: data,
          autoSpacing: true,
          enableSwipe: true,
          pageSnap: true,
          swipeHorizontal: true,
          nightMode: false,
        ),
      );
    } else {
      return const Text('No se puede mostrar el archivo o no hay archivo');
    }
  }

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

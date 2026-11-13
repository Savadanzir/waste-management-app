import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
class QrScanScreen extends StatelessWidget {

  final Function(String) onScanned;

  const QrScanScreen({
    super.key,
    required this.onScanned,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Scan House QR"),
        backgroundColor: Colors.green,
      ),

      body: MobileScanner(

        onDetect: (BarcodeCapture capture) {

          final barcode = capture.barcodes.first;

          final String? code = barcode.rawValue;

          if (code != null) {

            onScanned(code);

            Navigator.pop(context);

          }

        },

      ),

    );

  }

}
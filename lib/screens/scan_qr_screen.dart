import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatelessWidget {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escanear QR")),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final value = barcode.rawValue;
            if (value != null) {
              // ✅ Aquí puedes abrir directamente el detalle de la mascota
              Navigator.pushNamed(context, '/petDetail', arguments: value);
            }
          }
        },
      ),
    );
  }
}

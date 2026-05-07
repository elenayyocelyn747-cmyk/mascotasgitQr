import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escanear QR")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Apunta la cámara al código QR de la mascota",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                if (_scanned) return;
                final barcode = capture.barcodes.first;
                final petId = barcode.rawValue;
                if (petId != null) {
                  setState(() => _scanned = true);
                  Navigator.pushNamed(context, '/petDetail', arguments: petId);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

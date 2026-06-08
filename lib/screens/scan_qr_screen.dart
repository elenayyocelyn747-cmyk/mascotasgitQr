import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Escanear QR",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        // 👇 Fondo con gradiente adaptado
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey[900]!]
                : [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Apunta la cámara al código QR de la mascota",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Card(
                    elevation: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: MobileScanner(
                      fit: BoxFit.cover,
                      onDetect: (capture) {
                        if (_scanned) return;
                        final barcode = capture.barcodes.first;
                        final petId = barcode.rawValue;
                        if (petId != null) {
                          setState(() => _scanned = true);
                          Navigator.pushNamed(
                            context,
                            '/petDetail',
                            arguments: petId,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.qr_code_scanner,
                size: 48,
                color: isDark ? Colors.white70 : Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                "Escanea para abrir el perfil",
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.white,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

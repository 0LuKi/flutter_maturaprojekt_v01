import 'dart:async'; // <-- ADD THIS for the Timer
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_maturaprojekt_v01/models/animal.dart';
import 'package:flutter_maturaprojekt_v01/services/database_service.dart';
import 'cow_detail.dart';

class EarTagScannerPage extends StatefulWidget {
  final DatabaseService dbService;

  const EarTagScannerPage({super.key, required this.dbService});

  @override
  State<EarTagScannerPage> createState() => _EarTagScannerPageState();
}

class _EarTagScannerPageState extends State<EarTagScannerPage> {
  bool _isArmed = false; 
  bool _isProcessing = false;
  Timer? _timeoutTimer; // <-- We use this to stop the scan if nothing is found

  @override
  void dispose() {
    _timeoutTimer?.cancel(); // Always clean up timers when leaving the page
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isArmed || _isProcessing) return;
    
    final barcode = capture.barcodes.first;
    final code = barcode.rawValue;
    if (code == null) return;

    // We found a code! Cancel the timeout timer immediately.
    _timeoutTimer?.cancel();

    setState(() {
      _isArmed = false;
      _isProcessing = true;
    });

    // Search for cow by ear tag
    final animals = await widget.dbService.getAnimals().first;
    final found = animals.firstWhere(
      (a) => a.earTagNumber == code,
      orElse: () => Animal(
        id: 'unknown',
        earTagNumber: '',
        name: 'Unknown',
        birthDate: DateTime(2000, 1, 1),
        age: 0,
      ),
    );

    if (!mounted) return;

    if (found.earTagNumber == code) {
      _showSuccessDialog(found);
    } else {
      _showErrorDialog('Keine Kuh mit Ohrmarke $code gefunden.');
    }
  }

  void _startScanTimeout() {
    setState(() {
      _isArmed = true;
    });

    // Give the camera 3 seconds to find a barcode. 
    // You can increase or decrease this Duration.
    _timeoutTimer = Timer(const Duration(seconds: 3), () {
      if (_isArmed && mounted) {
        // If 3 seconds pass and it's STILL armed, it means no barcode was found.
        setState(() {
          _isArmed = false; 
        });
        _showErrorDialog('Es konnte kein Barcode erkannt werden. Bitte halten Sie die Kamera ruhiger oder näher an die Ohrmarke.');
      }
    });
  }

  void _showSuccessDialog(Animal found) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Kuh gefunden!', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Name: ${found.name}\nOhrmarke: ${found.earTagNumber}'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CowDetail(animal: found, dbService: widget.dbService),
                ),
              );
            },
            child: const Text('Details ansehen'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false); 
            },
            child: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Nicht erkannt', style: Theme.of(context).textTheme.titleLarge),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false); 
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ohrmarken-Scanner')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          
          if (_isArmed)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isArmed ? Colors.grey : Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                  elevation: 5.0,
                ),
                // Call our new timeout function when pressed
                onPressed: (_isArmed || _isProcessing) ? null : _startScanTimeout,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera, size: 28.0),
                    SizedBox(width: 12.0),
                    Text('Ohrmarke scannen', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_page.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  bool isConnecting = false;
  String? deviceId;

  final Guid glySenseServiceUUID = Guid("tentuindulumas");

  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkSavedDevice();
  }

  Future<void> checkSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('device_id');

    if (savedId != null) {
      deviceId = savedId;
      startScan();
    }
  }

  Future<void> saveDeviceId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_id', id);
    deviceId = id;
  }

  void startScan() async {
    setState(() => isConnecting = true);

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));

    FlutterBluePlus.scanResults.listen((results) async {
      for (final r in results) {
        if (r.advertisementData.serviceUuids.contains(
          glySenseServiceUUID.toString(),
        )) {
          FlutterBluePlus.stopScan();

          await r.device.connect(autoConnect: false);

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hubungkan Gly-Sense")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isConnecting
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Mencari gelang Gly-Sense..."),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Masukkan Kode Gelang",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: codeController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: "apalah",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final code = codeController.text.trim();
                        if (code.isEmpty) return;

                        await saveDeviceId(code);
                        startScan();
                      },
                      child: const Text("Hubungkan Gelang"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

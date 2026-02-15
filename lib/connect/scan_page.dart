import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../home/pages/home_page.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  BluetoothDevice? selectedDevice;

  Future<void> requestPermissions() async {
    try {
      await Permission.bluetooth.request();
      await Permission.bluetoothConnect.request();
      await Permission.location.request();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await requestPermissions();

    // 🔍 CEK DEVICE YANG SUDAH TERKONEKSI
    List<BluetoothDevice> connectedDevices =
        await FlutterBluePlus.connectedDevices;

    if (connectedDevices.isNotEmpty) {
      BluetoothDevice device = connectedDevices.first;

      print("✅ Sudah terkoneksi: ${device.name}");

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(device: device)),
        (route) => false,
      );

      return; // jangan scan lagi
    }

    FlutterBluePlus.adapterState.listen((state) {
      print("Adapter state: $state");
    });

    startScan();
  }

  Future<void> startScan() async {
    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    await FlutterBluePlus.stopScan();

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
      androidScanMode: AndroidScanMode.lowLatency,
    );

    FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;

      setState(() {
        scanResults = results.where((r) => r.device.name.isNotEmpty).toList();
      });
    });

    await Future.delayed(const Duration(seconds: 5)); // scanning 5 detik

    if (!mounted) return;

    setState(() {
      isScanning = false;
    });

    FlutterBluePlus.scanResults.listen((results) {
      print("Found devices: ${results.length}");
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(device: device)),
        (route) => false,
      );
    } catch (e) {
      print("Connection error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Pilih Perangkat"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () async {
              await startScan();
            },
            icon: Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: Column(
        children: [
          if (isScanning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final device = scanResults[index].device;

                return ListTile(
                  leading: const Icon(Icons.watch),
                  title: Text(
                    device.name.isNotEmpty ? device.name : "Unknown Device",
                  ),
                  subtitle: Text(device.id.id),
                  selected: selectedDevice?.id == device.id,
                  selectedTileColor: Colors.pink.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      selectedDevice = device;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedDevice == null
                    ? null
                    : () async {
                        try {
                          await FlutterBluePlus.stopScan();
                          await connectToDevice(selectedDevice!);
                        } catch (e) {
                          print("Error connect button: $e");
                        }
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE391DA),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  "Lanjut ke Beranda",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

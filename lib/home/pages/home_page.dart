import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:glysense_prototipe/models/home_model.dart';
import 'package:glysense_prototipe/services/home_service.dart';
import '../widgets/status_card.dart';
import '../widgets/device_status_card.dart';
import '../widgets/health_card.dart';

class HomePage extends StatefulWidget {
  final BluetoothDevice device;
  const HomePage({super.key, required this.device});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  String status = "";
  double heartRate = 0;
  double spo2 = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  void dispose() {
    dataSub.cancel();
    super.dispose();
  }

  // void fetchData() async {
  //   print("FETCH DATA DIPANGGIL");
  //   await Future.delayed(const Duration(seconds: 2));

  //   setState(() {
  //     status = "rendah";
  //     heartRate = 85;
  //     spo2 = 96;
  //     isLoading = false;
  //   });

  //   print("SETSTATE SELESAI");
  // }

  // void fetchData() async {
  //   try {
  //     final service = HomeService();
  //     final result = await service.fetchHealthData("GLYSENSE-001");

  //     setState(() {
  //       status = result.status;
  //       heartRate = result.heartRate;
  //       spo2 = result.spo2;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print("ERROR: $e");
  //   }
  // }

  late StreamSubscription<HomeModel> dataSub;

  void startListening() {
    final service = HomeService();

    dataSub = service.listenToHealthData(widget.device).listen((result) {
      setState(() {
        status = "AMAN"; // ini nanti API Call

        // Filter heartRate supaya hanya angka
        List<num> validHeartRate = result.heartRate
            .map((e) {
              if (e == null) return null;
              if (e is num) return e;
              if (e is String) return num.tryParse(e);
              return null;
            })
            .where((e) => e != null)
            .cast<num>()
            .toList();

        heartRate = validHeartRate.isNotEmpty
            ? validHeartRate.reduce((a, b) => a + b) / validHeartRate.length
            : 0;

        // Filter spo2 supaya hanya angka
        List<num> validSpO2 = result.spo2
            .map((e) {
              if (e == null) return null;
              if (e is num) return e;
              if (e is String) return num.tryParse(e);
              return null;
            })
            .where((e) => e != null)
            .cast<num>()
            .toList();

        spo2 = validSpO2.isNotEmpty
            ? validSpO2.reduce((a, b) => a + b) / validSpO2.length
            : 0;

        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedIndex == 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    /// HEADER
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/fotoprofile.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 11),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Selamat Siang,",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              "Lambertus Siregar",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Image.asset('assets/icons/notif.png'),
                      ],
                    ),

                    const SizedBox(height: 36),

                    StatusCard(status: status),

                    const SizedBox(height: 24),

                    const DeviceStatusCard(),

                    const SizedBox(height: 40),

                    const Text(
                      "Kondisi Terkini",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: HealthCard(
                            title: "Detak Jantung",
                            value: heartRate.toStringAsFixed(0),
                            unit: "bpm",
                            imagepath: 'assets/icons/jantung.png',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: HealthCard(
                            title: "Saturasi Oksigen",
                            value: spo2.toStringAsFixed(0),
                            unit: "%",
                            imagepath: 'assets/icons/oksigen.png',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : _buildPlaceholderPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE391DA),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Edukasi",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPage() {
    return const Center(
      child: Text("Coming Soon", style: TextStyle(fontSize: 18)),
    );
  }
}

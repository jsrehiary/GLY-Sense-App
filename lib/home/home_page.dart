import 'package:flutter/material.dart';
import 'home_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeService service = HomeService();

  String? statusGlikemik;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await service.fetchGlikemikStatus();
    setState(() {
      statusGlikemik = result;
      isLoading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "rendah":
        return Colors.green;
      case "sedang":
        return Colors.orange;
      case "tinggi":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gly-Sense")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: getStatusColor(statusGlikemik!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: getStatusColor(statusGlikemik!),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Status Glikemik",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      statusGlikemik!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: getStatusColor(statusGlikemik!),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loadData,
                      child: const Text("Refresh Data"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

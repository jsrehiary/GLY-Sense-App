import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/home_model.dart';

class HomeService {
  final Guid serviceUuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");

  final Guid characteristicUuid = Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  // ===============================
  // BUFFER
  // ===============================
  List<dynamic> hrBuffer = [];
  List<dynamic> spo2Buffer = [];

  Duration collectionDuration = const Duration(minutes: 1); // ADJUSTABLE
  Timer? _timer;

  void setCollectionDuration(Duration duration) {
    collectionDuration = duration;
  }

  // ===============================
  // LISTEN BLE
  // ===============================
  Stream<HomeModel> listenToHealthData(BluetoothDevice device) async* {
    List<BluetoothService> services = await device.discoverServices();

    BluetoothCharacteristic? targetChar;

    for (var service in services) {
      if (service.uuid == serviceUuid) {
        for (var c in service.characteristics) {
          if (c.uuid == characteristicUuid) {
            targetChar = c;
            break;
          }
        }
      }
    }

    if (targetChar == null) {
      throw Exception("Characteristic not found");
    }

    await targetChar.setNotifyValue(true);

    _startTimer(device); // start auto send timer

    await for (var value in targetChar.onValueReceived) {
      try {
        final jsonString = utf8.decode(value);
        final data = json.decode(jsonString);

        final model = HomeModel.fromJson(data);

        // Filter & simpan HR
        for (var hr in model.heartRate) {
          num? parsed = hr is num ? hr : num.tryParse(hr.toString());
          if (parsed != null) hrBuffer.add(parsed);
        }

        // Filter & simpan SpO2
        for (var sp in model.spo2) {
          num? parsed = sp is num ? sp : num.tryParse(sp.toString());
          if (parsed != null) spo2Buffer.add(parsed);
        }

        // 🔒 Batasi ukuran buffer (SETELAH add)
        const int maxBufferSize = 5000;

        if (hrBuffer.length > maxBufferSize) {
          hrBuffer.removeRange(0, hrBuffer.length - maxBufferSize);
        }

        if (spo2Buffer.length > maxBufferSize) {
          spo2Buffer.removeRange(0, spo2Buffer.length - maxBufferSize);
        }

        yield model;
      } catch (e) {
        print("❌ JSON error: $e");
      }
    }
  }

  // ===============================
  // TIMER AUTO SEND
  // ===============================
  void _startTimer(BluetoothDevice device) {
    _timer?.cancel();

    _timer = Timer(collectionDuration, () async {
      print("⏰ Auto sending data...");
      await sendToApi(deviceId: device.remoteId.str);
    });
  }

  // ===============================
  // FORCE SEND (Manual)
  // ===============================
  Future<void> forceSend(String deviceId) async {
    print("🚀 Force send triggered");
    await sendToApi(deviceId: deviceId);
  }

  // ===============================
  // SEND TO API
  // ===============================
  Future<void> sendToApi({required String deviceId}) async {
    if (hrBuffer.isEmpty || spo2Buffer.isEmpty) {
      print("Buffer kosong, tidak dikirim.");
      return;
    }

    final payload = {
      "data": [
        {
          "device_id": deviceId,
          "umur": 25, // ya ini tolong dianukan supaya sesuai user
          "berat": 66, // ya ini tolong dianukan supaya sesuai user
          "tinggi": 165, // ya ini tolong dianukan supaya sesuai user
          "heartrate": hrBuffer,
          "spo2": spo2Buffer,
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(
          "https://lonelyhina-gly-sense.hf.space/gradio_api/call/core_processing",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("📡 API STATUS: ${response.statusCode}");
      print("📡 API RESPONSE: ${response.body}");

      // clear buffer setelah sukses kirim
      hrBuffer.clear();
      spo2Buffer.clear();
    } catch (e) {
      print("❌ API Error: $e");
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

import 'dart:math';

class HomeService {
  Future<String> fetchGlikemikStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final data = ["rendah", "sedang", "tinggi"];
    return data[Random().nextInt(data.length)];
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class HomeService {
//   final String baseUrl = "link API";

//   Future<String> fetchGlikemikStatus() async {
//     final response = await http.get(
//       Uri.parse("$baseUrl/status"),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data["status"]; // "rendah" | "sedang" | "tinggi"
//     } else {
//       throw Exception("Gagal mengambil data glikemik");
//     }
//   }
// }

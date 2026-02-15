class HomeModel {
  List<dynamic> heartRate;
  List<dynamic> spo2;
  final double battery;

  HomeModel({
    required this.heartRate,
    required this.spo2,
    required this.battery,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      heartRate: json["hr"] is List ? json["hr"] : [],
      spo2: json["spo2"] is List ? json["spo2"] : [],
      battery: (json["battery"] ?? 0).toDouble(),
    );
  }
}

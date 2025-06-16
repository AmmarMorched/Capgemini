

import '../../domaine/entities/Vehicule.dart';

class VehiculeModel extends Vehicule {
  VehiculeModel({
    int? vid,
    required String marque,
    required String model,
    required int? year,
  }) : super(
    Vid: vid,
    marque: marque,
    model: model,
    year: year,
  );

  factory VehiculeModel.fromMap(Map<String, dynamic> json) => VehiculeModel(
    vid: json["Vid"],
    marque: json["marque"] ?? "Unknown",
    model: json["model"] ?? "Unknown",
    year: json["year"],
  );

  Map<String, dynamic> toMap() => {
    "Vid": Vid,
    "marque": marque,
    "model": model,
    "year": year,
  };
}

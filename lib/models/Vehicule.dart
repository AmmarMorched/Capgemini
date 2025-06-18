

import 'Users.dart';

class Vehicule {
  final int? Vid;
  final String marque;
  final String model;
  final int? year;
  final Users user;

  Vehicule({
    this.Vid,
    required this.marque,
    required this.model,
    required this.year,
    required this.user,  // Default to an empty Users object if not provided
     // Optional user field

  });

  factory Vehicule.fromMap(Map<String, dynamic> json) => Vehicule(
    Vid: json["Vid"],
    marque: json["marque"],
    model: json["model"],
    year: json["year"] != null ? json["year"] : null,
    user: Users.fromMap(json["user"]), // Handle nullable year
  );

  Map<String, dynamic> toMap() => {
    "Vid": Vid,
    "marque": marque,
    "model": model,
    "year": year,
    "user": user.toMap(), // Convert Users object to map
  };

}
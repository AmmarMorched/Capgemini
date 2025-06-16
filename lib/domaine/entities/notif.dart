
import 'User.dart';

class Notif {
  final int ? Notif_id;
  final String type;
  final String message;
  final DateTime date_envoie;
  final Users user;

  Notif({
    this.Notif_id,
    required this.type,
    required this.message,
    required this.date_envoie,
    required this.user
});

  factory Notif.fromMap(Map<String, dynamic>json )=>Notif(
  Notif_id: json["Notif_id"],
  type: json["type"],
  message: json["message"],
  date_envoie: DateTime.parse(json["date_envoie"]), // Convert from string to DateTime
  user: Users.fromMap(json["user"]), // Assuming Users has a fromMap method
  );
// Method to convert Notif to a map
      Map<String, dynamic> toMap() => {
  "Notif_id": Notif_id,
  "type": type,
  "message": message,
  "date_envoie": date_envoie.toIso8601String(), // Convert DateTime to string
  "user": user.toMap(),  // Assuming Users has a toMap method
  };
}
//
//
// import 'Diagnostic.dart';
// import 'Vehicule.dart';
//
// class DiagHistory {
//   final String id;
//   final Vehicule vehicule;
//   final Diagnostic diagnostic;
//   final DateTime date_diag;
//
//   DiagHistory({
//     required this.id,
//     required this.vehicule,
//     required this.diagnostic,
//     required this.date_diag,
// });
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'voiture': vehicule.toMap(),
//       'diagnostic': diagnostic.toMap(),
//       'date_diag': date_diag.toIso8601String(),
//     };
//   }
//   factory DiagHistory.fromMap(Map<String, dynamic> map) {
//     return DiagHistory(
//       id: map['id'],
//       vehicule: Vehicule.fromMap(map['voiture']),
//       diagnostic: Diagnostic.fromMap(map['diagnostic']),
//       date_diag: DateTime.parse(map['date_diag']),
//     );
//   }
// }
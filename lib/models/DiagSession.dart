//
//
// import 'package:capgemini/domaine/entities/Vehicule.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'Diagnostic.dart';
// import 'OBDConnect.dart';
// import 'Users.dart';
//
// class DiagSession{
//   final String session_id;
//   final Vehicule vehicule;
//   final Users user;
//   final ObdConnect obdConnect;
//   final Diagnostic diag_en_cours;
//
//   DiagSession({
//     required this.session_id,
//     required this.vehicule,
//     required this.user,
//     required this.obdConnect,
//     required this.diag_en_cours,
// });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'session_id': session_id,
//       'voiture': vehicule.toMap(),
//       'user': user.toMap(),
//       'obdConnect': obdConnect.toMap(),
//       'diag_en_cours': diag_en_cours.toMap(),
//     };
//   }
//   factory DiagSession.fromMap(Map<String, dynamic> map) {
//     return DiagSession(
//       session_id: map['session_id'],
//       vehicule: Vehicule.fromMap(map['voiture']),
//       user: Users.fromMap(map['user']),
//       obdConnect: ObdConnect.fromMap(map['obdConnect']),
//       diag_en_cours: Diagnostic.fromMap(map['diag_en_cours']),
//     );
//   }
// }
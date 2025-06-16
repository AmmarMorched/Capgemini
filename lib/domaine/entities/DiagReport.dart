// import 'package:uuid/uuid.dart';
// import 'DiagSession.dart';
//
// class DiagReport {
//   final String id;
//   final DiagSession session;
//   final String resumer;
//   final String details;
//   final String conclusion;
//   final String recommendation;
//
//   DiagReport({
//     String? id,
//     required this.session,
//     required this.resumer,
//     required this.details,
//     required this.conclusion,
//     required this.recommendation,
// }): id = id ?? Uuid().v4();
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'session': session.toMap(),
//       'resumer': resumer,
//       'details': details,
//       'conclusion': conclusion,
//       'recommendation': recommendation,
//     };
//   }
//
//   factory DiagReport.fromMap(Map<String, dynamic> map) {
//     return DiagReport(
//       id: map['id'],
//       session: DiagSession.fromMap(map['session']),
//       resumer: map['resumer'],
//       details: map['details'],
//       conclusion: map['conclusion'],
//       recommendation: map['recommendation'],
//     );
//   }
// }
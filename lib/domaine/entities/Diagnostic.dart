

import 'package:uuid/uuid.dart';

class Diagnostic {
  final String id;
  final String error_code;
  final String description;
  final String gravity;
  final DateTime last_diag;


  Diagnostic({
    String? id,
    required this.error_code,
    required this.description,
    required this.gravity,
    required this.last_diag,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'error_code': error_code,
      'description': description,
      'gravity': gravity,
      'last_diag': last_diag.toIso8601String(),

    };
  }

  factory Diagnostic.fromMap(Map<String, dynamic> map) {
    return Diagnostic(
      id: map['id'],
      error_code: map['error_code'],
      description: map['description'],
      gravity: map['gravity'],
      last_diag: DateTime.parse(map['last_diag']),
    );
  }
}

class ObdConnect {
  final String id_session;
  final String connection_type;
  final String con_status;

  ObdConnect({
    required this.id_session,
    required this.connection_type,
    required this.con_status,
});

  Map<String, dynamic> toMap() {
    return {
      'id_session': id_session,
      'connection_type': connection_type,
      'con_status': con_status,
    };
  }


  factory ObdConnect.fromMap(Map<String, dynamic> map) {
    return ObdConnect(
      id_session: map['id_session'],
      connection_type: map['connection_type'],
      con_status: map['con_status'],
    );
  }

}

class Users {
  final int? usrId;
  final String usrName;
  final String usrPassword;
  final String usrEmail;
  final int phone;
  final String? profileImageUrl;

  Users({
    this.usrId,
    required this.usrName,
    required this.usrPassword,
    required this.usrEmail,
    required this.phone,
    this.profileImageUrl
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
    usrId: json["usrId"],
    usrName: json["usrName"],
    usrPassword: json["usrPassword"],
    usrEmail : json["usrEmail"],
    phone: json["phone"],
    profileImageUrl: json["profileImageUrl"],

  );

  Map<String, dynamic> toMap() => {
    "usrId": usrId,
    "usrName": usrName,
    "usrPassword": usrPassword,
    "usrEmail": usrEmail,
    "phone":phone,
    "profileImageUrl": profileImageUrl,
  };
}
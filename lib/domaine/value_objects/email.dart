class Email {
  final String value;

  factory Email(String email) {
    return Email._validate(email);
  }

  Email._(this.value);

  static Email _validate(String email) {
    if (email.isEmpty) {
      throw InvalidEmailException(message: 'Email cannot be empty');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      throw InvalidEmailException(message: 'Invalid email format');
    }
    return Email._(email);
  }
}

class InvalidEmailException implements Exception {
  final String message;

  InvalidEmailException({required this.message});
}

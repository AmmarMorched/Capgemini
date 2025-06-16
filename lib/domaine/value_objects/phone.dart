class Phone {
  final int value;

  factory Phone(int phone) {
    return Phone._validate(phone);
  }

  Phone._(this.value);

  static Phone _validate(int phone) {
    if (phone <= 0) {
      throw InvalidPhoneException(message: 'Phone number must be positive');
    }
    if (phone.toString().length < 10) {
      throw InvalidPhoneException(message: 'Phone number too short');
    }
    return Phone._(phone);
  }
}

class InvalidPhoneException implements Exception {
  final String message;

  InvalidPhoneException({required this.message});
}

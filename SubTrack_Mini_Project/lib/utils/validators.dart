bool isValidEmail(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
}

bool isValidPassword(String password) {
  return password.length >= 6;
}

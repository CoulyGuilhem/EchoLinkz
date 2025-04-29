
class Validators {
  static final _emailRegExp =
      RegExp(r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,}$');

  static final _passwordRegExp =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$');

  static bool isValidEmail(String value) =>
      _emailRegExp.hasMatch(value.trim());

  static bool isValidPassword(String value) =>
      _passwordRegExp.hasMatch(value);
}

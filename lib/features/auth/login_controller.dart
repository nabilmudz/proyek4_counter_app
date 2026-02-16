class LoginController {
  final List<Map<String, String>> users = [
    {'username': 'admin', 'password': '123'},
    {'username': 'nabil', 'password': 'abc'},
  ];

  bool login(String username, String password) {
    return users.any(
      (user) => user['username'] == username && user['password'] == password,
    );
  }
}

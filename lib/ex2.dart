import 'dart:async';
import 'dart:convert';

class User {
  final String name;
  final String email;

  User(this.name, this.email);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['name'], json['email']);
  }

  @override
  String toString() => 'User(name: $name, email: $email)';
}

Future<List<User>> fetchUsers() async {
  await Future.delayed(Duration(milliseconds: 200));

  final jsonData = '''
  [
    {"name": "Ada", "email": "ada@test.com"},
    {"name": "Alan", "email": "alan@test.com"}
  ]
  ''';

  final decoded = jsonDecode(jsonData) as List;
  return decoded.map((e) => User.fromJson(e)).toList();
}

Future<void> main() async {
  final users = await fetchUsers();
  print('Users from API:');
  users.forEach(print);
}
class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      createdAt: map['created_at'],
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email}';
  }
}
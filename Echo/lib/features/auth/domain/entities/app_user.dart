class AppUser {
  final String uid;
  final String email;
  final String name;
  final String? birthDate;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.birthDate,
  });

  // converte o app user em json

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'name': name, 'birthDate': birthDate};
  }

  //converte json em app user

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
      name: jsonUser['name'],
      birthDate: jsonUser['birthDate'],
    );
  }
}

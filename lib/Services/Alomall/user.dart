class AloUser {
  final String uid;
  final String name;
  final String phone;
  final String token;
  final String refreshToken;
  final String? photoURL;

  AloUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.token,
    required this.refreshToken,
    this.photoURL,
  });
}
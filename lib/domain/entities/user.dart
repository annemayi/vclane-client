class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String address;
  final String phoneNumber;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.address = '',
    this.phoneNumber = '',
    this.role = 'operator',
  });
}

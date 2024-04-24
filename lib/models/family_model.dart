// family_model.dart
class Family {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;

  Family(
      {required this.id,
      required this.name,
      required this.email,
      required this.phoneNumber});

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
        id: json['_id'],
        name: json['name'],
        email: json['email'],
        phoneNumber: json['phoneNumber']);
  }
}

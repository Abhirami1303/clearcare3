class Medicine {
  final String id;
  final String name;
  final int quantity;
  final List<String> timings;
  final DateTime expiryDate;

  Medicine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.timings,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['_id'],
      name: json['name'],
      quantity: json['quantity'],
      expiryDate: DateTime.parse(json['expiryDate']),
      timings: List<String>.from(json['timings']),
    );
  }
}

class Batch {
  final int id;
  final String name;

  Batch({required this.id, required this.name});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(id: json['id'], name: json['name']);
  }
}

class Training {
  final int id;
  final String name;

  Training({required this.id, required this.name});

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(id: json['id'], name: json['name']);
  }
}

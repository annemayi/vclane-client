class Group {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final DateTime createdAt;

  const Group({
    required this.id,
    required this.name,
    this.description,
    this.location,
    required this.createdAt,
  });
}

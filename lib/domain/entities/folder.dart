class Folder {
  final int? id;
  final String name;
  final DateTime createdAt;
  final int color; // ARGB value
  final bool isLocked;

  Folder({
    this.id,
    required this.name,
    required this.createdAt,
    required this.color,
    this.isLocked = false,
  });

  Folder copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    int? color,
    bool? isLocked,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

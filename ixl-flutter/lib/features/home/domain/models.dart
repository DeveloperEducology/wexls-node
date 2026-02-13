class GradeModel {
  final String id;
  final String name;
  final String slug;
  final String? colorHex;
  final int sortOrder;

  GradeModel({
    required this.id,
    required this.name,
    required this.slug,
    this.colorHex,
    required this.sortOrder,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) => GradeModel(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Unknown Grade',
        slug: json['slug'] ?? '',
        colorHex: json['color_hex'],
        sortOrder: json['sort_order'] ?? 0,
      );
}

class SubjectModel {
  final String id;
  final String name;
  final String slug;

  SubjectModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
      );
}

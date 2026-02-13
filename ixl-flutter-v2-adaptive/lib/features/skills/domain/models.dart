class MicroSkillModel {
  final String id;
  final String unitId;
  final String name;
  final String code;
  final int sortOrder;

  MicroSkillModel({
    required this.id,
    required this.unitId,
    required this.name,
    required this.code,
    required this.sortOrder,
  });

  factory MicroSkillModel.fromJson(Map<String, dynamic> json) => MicroSkillModel(
        id: json['id'],
        unitId: json['unit_id'],
        name: json['name'],
        code: json['code'],
        sortOrder: json['sort_order'],
      );
}

class UnitModel {
  final String id;
  final String name;
  final String code;
  final int sortOrder;
  final List<MicroSkillModel> skills;

  UnitModel({
    required this.id,
    required this.name,
    required this.code,
    required this.sortOrder,
    this.skills = const [],
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) => UnitModel(
        id: json['id'],
        name: json['name'],
        code: json['code'],
        sortOrder: json['sort_order'],
        skills: json['micro_skills'] != null 
            ? (json['micro_skills'] as List).map((e) => MicroSkillModel.fromJson(e)).toList() 
            : [],
      );
}

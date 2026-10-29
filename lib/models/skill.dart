class Skill {
  final int? skillId;
  final String name;
  final String category;
  final int difficulty;
  final int targetHours;
  final int treeLevel;
  final String dateCreated;

  Skill({
    this.skillId,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.targetHours,
    required this.treeLevel,
    required this.dateCreated,
  });
}

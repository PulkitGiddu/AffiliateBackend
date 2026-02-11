/// Category model from backend.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
  });

  final String id;
  final String name;
  final String slug;
  final String? parentId;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'slug': slug, 'parentId': parentId};
}

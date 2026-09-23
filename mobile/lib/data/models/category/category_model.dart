import '../../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    required super.minVisitingCharge,
    super.iconUrl,
    super.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      minVisitingCharge: double.tryParse(json['min_visiting_charge']?.toString() ?? '0') ?? 0.0,
      iconUrl: json['icon_url'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'min_visiting_charge': minVisitingCharge,
      'icon_url': iconUrl,
      'sort_order': sortOrder,
    };
  }
}

import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final double minVisitingCharge;
  final String? iconUrl;
  final int sortOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.minVisitingCharge,
    this.iconUrl,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, name, slug, description, minVisitingCharge, iconUrl, sortOrder];
}

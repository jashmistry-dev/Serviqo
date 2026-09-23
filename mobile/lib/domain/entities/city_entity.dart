import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final String id;
  final String name;
  final String state;
  final String pincode;

  const CityEntity({
    required this.id,
    required this.name,
    required this.state,
    required this.pincode,
  });

  @override
  List<Object?> get props => [id, name, state, pincode];
}

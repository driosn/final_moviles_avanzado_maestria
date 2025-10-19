import 'package:equatable/equatable.dart';

enum City { laPaz, cochabamba, santaCruz }

class Store extends Equatable {
  final String id;
  final String name;
  final City city;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Store({
    required this.id,
    required this.name,
    required this.city,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [id, name, city, createdAt, updatedAt];

  Store copyWith({String? id, String? name, City? city, DateTime? createdAt, DateTime? updatedAt}) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

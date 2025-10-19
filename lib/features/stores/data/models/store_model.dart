import '../../domain/entities/store.dart' as domain;

class StoreModel extends domain.Store {
  const StoreModel({
    required super.id,
    required super.name,
    required super.city,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      city: _parseCity(json['city'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory StoreModel.fromSupabase(Map<String, dynamic> data) {
    return StoreModel(
      id: data['id'] as String,
      name: data['name'] as String,
      city: _parseCity(data['city'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  static domain.City _parseCity(String city) {
    switch (city.toLowerCase()) {
      case 'la_paz':
        return domain.City.laPaz;
      case 'cochabamba':
        return domain.City.cochabamba;
      case 'santa_cruz':
        return domain.City.santaCruz;
      default:
        return domain.City.laPaz; // Default city
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': _cityToString(city),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {'name': name, 'city': _cityToString(city), 'updated_at': DateTime.now().toIso8601String()};
  }

  String _cityToString(domain.City city) {
    switch (city) {
      case domain.City.laPaz:
        return 'la_paz';
      case domain.City.cochabamba:
        return 'cochabamba';
      case domain.City.santaCruz:
        return 'santa_cruz';
    }
  }

  String get cityDisplayName {
    switch (city) {
      case domain.City.laPaz:
        return 'La Paz';
      case domain.City.cochabamba:
        return 'Cochabamba';
      case domain.City.santaCruz:
        return 'Santa Cruz';
    }
  }
}

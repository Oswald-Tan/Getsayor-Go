class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Province {
  final int id;
  final String name;
  final List<City> cities;

  Province({required this.id, required this.name, required this.cities});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
      cities:
          (json['cities'] as List).map((city) => City.fromJson(city)).toList(),
    );
  }
}

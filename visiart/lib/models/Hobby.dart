class Hobby {
  final int id;
  final String name;
  bool isSelected = false;

  Hobby({this.id, this.name});

  factory Hobby.fromJson(Map<String, dynamic> json) {
    return Hobby(
        id: json['id'],
        name: json['name']
    );
  }
}
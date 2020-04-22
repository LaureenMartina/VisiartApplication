class Room {
  final int id;
  final String name;

  Room({this.id, this.name});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name_fr']
    );
  }
}
class RoomMessage {
  final int id;
  final int userId;
  final String content;

  RoomMessage({this.id, this.content, this.userId});

  factory RoomMessage.fromJson(Map<String, dynamic> json) {
    return RoomMessage(
      id: json['id'],
      content: json['content'],
      userId: json['user']['id']
    );
  }
}
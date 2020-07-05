import 'package:intl/intl.dart';

class RoomMessage {
  final int id;
  final int roomId;
  final int userId;
  final String content;
  final String username;
  final String date;

  RoomMessage({this.id, this.roomId, this.content, this.userId, this.username, this.date});

  factory RoomMessage.fromJson(Map<String, dynamic> json) {
    
    var userId = json['user'];
    if (userId != null){
      userId = json['user'];
    }

    var parsedDate = DateTime.parse(json['created_at']);
    
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
   

    return RoomMessage(
      id: json['id'],
      content: json['content'],
      userId: userId,
      date: formatter.format(parsedDate)
    );
  }

  factory RoomMessage.fromMainJson(Map<String, dynamic> json) {
    
    var userId = json['user'];
    var username = json['user'];

    if (userId != null){
      userId = json['user']['id'];
      username = json['user']['username'];
    }
  
    var roomId = json['room'];
    if (roomId != null){
      roomId = json['room']['id'];
    }
    var parsedDate = DateTime.parse(json['created_at']);
    
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    return RoomMessage(
      id: json['id'],
      content: json['content'],
      userId: userId,
      roomId: roomId,
      username: username,
      date: formatter.format(parsedDate)
    );
  }
}
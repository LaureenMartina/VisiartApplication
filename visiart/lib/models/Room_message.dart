import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class RoomMessage {
  final int id;
  final int roomId;
  final int userId;
  final String playerId;
  final String content;
  final String username;
  final String date;

  RoomMessage({this.id, this.roomId, this.content, this.userId, this.username, this.date, this.playerId});

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
    var username = "";
    var playerId = "";

    if (userId != null){
      userId = json['user']['id'];
      username = json['user']['username'];
      playerId = json['user']['playerId'];
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
      playerId: playerId,
      date: formatter.format(parsedDate)
    );
  }
}
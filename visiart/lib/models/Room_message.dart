import 'package:flutter/foundation.dart';

class RoomMessage {
  final int id;
  final int userId;
  final String content;

  RoomMessage({this.id, this.content, this.userId});

  factory RoomMessage.fromJson(Map<String, dynamic> json) {
    
    var userId = json['user'];
    if (userId == null){
      userId = null;
    } else {
      userId = json['user'];
    }

    return RoomMessage(
      id: json['id'],
      content: json['content'],
      userId: userId
    );
  }
}
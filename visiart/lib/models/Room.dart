import 'package:visiart/models/Room_message.dart';
import 'dart:async' show Future;
import 'dart:convert';

class Room {
  final int id;
  final String name;
  final int userId;
  final bool private;
  final bool enabled;
  final bool display;

  final List<RoomMessage> roomMessages;

  Room({this.private, this.enabled, this.display, this.id, this.name, this.userId, this.roomMessages});

  factory Room.fromJson(Map<String, dynamic> json) {
    var list = json['room_messages'] as List;
    List<RoomMessage> messageList = list.map((value) => RoomMessage.fromJson(value)).toList();//RoomMessage.fromJson(index)).toList();

    var userId = json['user'];
    if (userId == null){
      userId = null;
    } else {
      userId = json['user']['id'];
    }

    return Room(
      id: json['id'],
      name: json['name'],
      private: json['private'],
      enabled: json['enabled'],
      display: json['display'],
      userId: userId,
      roomMessages: messageList
    );
  }
}
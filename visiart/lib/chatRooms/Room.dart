import 'package:visiart/models/Room_message.dart';
import 'dart:async' show Future;
import 'dart:convert';

class Room {
  final int id;
  final String name;
  final List<RoomMessage> roomMessages;

  Room({this.id, this.name, this.roomMessages});

  factory Room.fromJson(Map<String, dynamic> json) {
    var list = json['room_messages'] as List;
    List<RoomMessage> messageList = list.map((value) => RoomMessage.fromJson(value)).toList();//RoomMessage.fromJson(index)).toList();

    return Room(
      id: json['id'],
      name: json['name'],
      roomMessages: messageList
    );
  }
}
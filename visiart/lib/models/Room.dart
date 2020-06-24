import 'package:visiart/models/Hobby.dart';
import 'package:visiart/models/Room_message.dart';
import 'dart:async' show Future;
import 'dart:convert';

class Room {
  final int id;
  final String name;
  final int userId;
  final int hobbyId;
  final bool private;
  final bool enabled;
  final bool display;

  final List<RoomMessage> roomMessages;
  final List<Hobby> hobbies;

  Room({this.private, this.enabled, this.display, this.id, this.name, this.userId, this.hobbyId, this.roomMessages, this.hobbies});

  factory Room.fromJson(Map<String, dynamic> json) {
    var list = json['room_messages'] as List;
    List<RoomMessage> messageList;
    if (list != null) {
      messageList = list.map((value) => RoomMessage.fromJson(value)).toList();//RoomMessage.fromJson(index)).toList();
    }

    var listHobbies = json['hobbies'] as List;
    List<Hobby> currentListHobbies;
    if (listHobbies != null) {
      currentListHobbies = listHobbies.map((hobby) => Hobby.fromJson(hobby)).toList();//RoomMessage.fromJson(index)).toList();
    }
    
    var userId = json['user'];
    if (userId != null){
      if (userId is int) {
        //Problème in modele
      } else {
        userId = json['user']['id'];
      }
    }

    return Room(
      id: json['id'],
      name: json['name'],
      private: json['private'],
      enabled: json['enabled'],
      display: json['display'],
      userId: userId,
      roomMessages: messageList,
      hobbies: currentListHobbies,
    );
  }
}
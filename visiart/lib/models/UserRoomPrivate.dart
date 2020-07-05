import 'package:visiart/models/Room.dart';
import 'package:visiart/models/User.dart';

class UserRoomPrivate {
  final int id;
  final User user;
  final Room room;


  UserRoomPrivate({this.id, this.user, this.room});

  factory UserRoomPrivate.fromJson(Map<String, dynamic> json) {
    User user = User.fromJson(json['user']);
    Room room = Room.fromJson(json['room']);

    return UserRoomPrivate(
      id: json['id'],
      user: user,
      room: room,
    );
  }
}
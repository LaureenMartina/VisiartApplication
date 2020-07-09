import 'package:visiart/models/Event.dart';
import 'package:visiart/models/User.dart';

class UserEventFavorite {
  final int id;
  final User user;
  final Event event;
  final bool favorite;

  UserEventFavorite({this.id, this.user, this.event, this.favorite});

  factory UserEventFavorite.fromJson(Map<String, dynamic> json) {
    User user = User.fromJson(json['user']);
    Event event = Event.fromJson(json['event']);

    return UserEventFavorite(
      id: json['id'],
      user: user,
      event: event,
      favorite: json['favorite']
    );
  }
}
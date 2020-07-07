import 'package:visiart/models/User.dart';

class Drawing {
  final int id;
  final String urlImage;
  final User user;
  
  Drawing({this.id, this.urlImage, this.user});

  factory Drawing.fromJson(Map<String, dynamic> json) {
    User user = User.fromJson(json['user']);

    return Drawing(
      id: json['id'],
      urlImage : json['urlImage'],
      user: user
    );
  }

}
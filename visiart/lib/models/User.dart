class User {
  String id;
  String username;
  String name;
  String firstname;
  String email;
  String password = ""; //TODO change if basic connexion
  bool confirmed;
  String phone;
  String language;
  String role;

  User({this.id, this.name, this.email});
  User.fromUser(this.name, this.email);

  void setUsername(String name) {
    this.username = name;
  }

  String getUsername() {
    return this.username;
  }

  void setEmail(String mail) {
    this.email = mail;
  }

  String getEmail() {
    return this.email;
  }

  void setPassword() {}

  User.fromJson(Map<String, String> json) :
    id = json['id'],
    name = json['name'],
    email = json['email']
  ;

}
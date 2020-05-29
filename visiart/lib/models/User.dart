class User {
  int id;
  String token;
  String username;
  String name;
  String firstname;
  String email;
  String password = ""; //TODO change if basic connexion
  //bool confirmed;
  String phone;
  String language;
  String role;

  User({this.id, this.name, this.email});
  User.fromUser(this.name, this.email);

  void setId(int id) {
    this.id = id;
  }
  int getId() {
    return this.id;
  }

  void setToken(String token) {
    this.token = token;
  }
  String getToken() {
    return this.token;
  }

  void setUsername(String name) {
    this.username = name;
  }
  String getUsername() {
    return this.username;
  }

  void setName(String name) {
    this.name = name;
  }
  String getName() {
    return this.name;
  }

  void setEmail(String mail) {
    this.email = mail;
  }
  String getEmail() {
    return this.email;
  }

  void setPassword() {}

  User.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    name = json['name'],
    email = json['email']
  ;

}
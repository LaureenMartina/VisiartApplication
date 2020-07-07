class Event {
  final int id;
  final int recordId;
  final String url;
  final String title;
  final String description;
  final String longDescription;
  final String city;
  final String language; 
  final String image;
  final String region;
  final List<double> geoJson;
  final String startDate;
  final String endDate;
  final int postalcode;
  final String location;
  final String urlSite;
  final String labelSite;
  //final bool favorite;


  Event({this.id, this.recordId, this.url, this.title, this.description, this.longDescription, this.city, 
  this.language, this.image, this.region, this.geoJson, this.startDate, this.endDate, this.postalcode, this.location,
  this.urlSite, this.labelSite/*, this.favorite*/});

  factory Event.fromJson(Map<String, dynamic> json) {
    List<double> geoList = json['geoJson'].cast<double>();
     //var list = json['geoJson'] as List;
     //print("list: $list");

    return Event(
      id : json['id'],
      recordId : json['recordId'],
      url : json['url'],
      title : json['title'],
      description : json['description'],
      longDescription : json['longDescription'],
      city : json['city'],
      language : json['language'],
      image : json['image'],
      region : json['region'],
      geoJson : geoList,
      startDate : json['startDate'],
      endDate : json['endDate'],
      postalcode : json['postalcode'],
      location : json['location'],
      urlSite : json['urlSite'],
      labelSite : json['labelSite']//,
      //favorite: json['favorite']
    );
  }
}

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
  //final Map<int, int> geoJson;
  final String startDate;
  final String endDate;
  final int postalcode;
  final String location;
  final String urlSite;
  final String labelSite;


  Event({this.id, this.recordId, this.url, this.title, this.description, this.longDescription, this.city, 
  this.language, this.image, this.region, /*this.geoJson,*/ this.startDate, this.endDate, this.postalcode, this.location,
  this.urlSite, this.labelSite});

  factory Event.fromJson(Map<String, dynamic> json) {
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
      //geoJson : json['geoJson'],
      startDate : json['startDate'],
      endDate : json['endDate'],
      postalcode : json['postalcode'],
      location : json['location'],
      urlSite : json['urlSite'],
      labelSite : json['labelSite']
    );
  }
}

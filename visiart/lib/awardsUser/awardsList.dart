import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:visiart/dashboard/dashboard.dart';
import 'package:visiart/dashboard/menu.dart';

class AwardsListScreen extends StatefulWidget {
  @override
  _AwardsListScreenState createState() => _AwardsListScreenState();
}

class _AwardsListScreenState extends State<AwardsListScreen> {

  bool curiousBadgeEnabled = true;
  bool investedBadgeEnabled = false;
  bool reagentBadgeEnabled = false;
  bool passionateBadgeEnabled = false;

  String _setCuriousImage() {
    String _imageBadge = "";
    if(curiousBadgeEnabled) {
      _imageBadge = "assets/imgs/curieux.png";
    }else{
      _imageBadge = "assets/imgs/coming-soon.png";
    }
    return _imageBadge;
  }

  String _setInvestedImage() {
    String _imageBadge = "";
    int counterInvested = 0;
    int finalCounter = 5;

    if(investedBadgeEnabled && counterInvested >= finalCounter) {
      _imageBadge = "assets/imgs/investi.png";
    }else{
      _imageBadge = "assets/imgs/coming-soon.png";
    }
    return _imageBadge;
  }

  String _setReagentImage() {
    String _imageBadge = "";
    int counterInvested = 0;
    int finalCounter = 5;

    if(reagentBadgeEnabled && counterInvested >= finalCounter) {
      _imageBadge = "assets/imgs/reactif.png";
    }else{
      _imageBadge = "assets/imgs/coming-soon.png";
    }
    return _imageBadge;
  }

  String _setPassionateImage() {
    String _imageBadge = "";

    if(passionateBadgeEnabled && (curiousBadgeEnabled && investedBadgeEnabled && reagentBadgeEnabled)) {
      _imageBadge = "assets/imgs/passionne.png";
    }else{
      _imageBadge = "assets/imgs/coming-soon.png";
    }
    return _imageBadge;
  }


  Padding _titleCuriousBadge() => Padding(
    padding: EdgeInsets.only(top: 10),
    child: Text(
      'Badge Curieux',
      maxLines: 3,
      softWrap: true,
    ),
  );
  
  Padding _titleInvestedBadge() => Padding(
    padding: EdgeInsets.all(10),
    child: Text(
      'Badge Investi',
      maxLines: 3,
      softWrap: true,
    ),
  );
  
  Padding _titleReagentBadge() => Padding(
    padding: EdgeInsets.only(top: 10),
    child: Text(
      'Badge Réactif',
      maxLines: 3,
      softWrap: true,
    ),
  );

  Padding _titlePasionateBadge() => Padding(
    padding: EdgeInsets.all(10),
    child: Text(
      'Badge Passionné',
      maxLines: 3,
      softWrap: true,
    ),
  );


  Flexible _imageCuriousBadge() => Flexible(
    child: Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        /*gradient: new LinearGradient(
          colors: [Colors.blueGrey, Colors.blueGrey[700]],
        ),*/
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(_setCuriousImage()),
        ),
      ),
    ),
  );

  Flexible _imageInvestedBadge() => Flexible(
    child: Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(_setInvestedImage()),
        ),
      ),
    ),
  );

  Flexible _imageReagentBadge() => Flexible(
    child: Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        /*gradient: new LinearGradient(
          colors: [Colors.brown, Colors.deepOrange[900]],
        ),*/
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(_setReagentImage()),
        ),
      ),
    ),
  );

  Flexible _imagePassionateBadge() => Flexible(
    child: Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(_setPassionateImage()),
        ),
      ),
    ),
  );


  Card _curiousCard() => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50)
    ),
    color: Colors.transparent,
    child: Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _imageCuriousBadge(),
            _titleCuriousBadge(),
          ],
        ),
      ),
    ),
  );

  Card _investedCard() => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50)
    ),
    color: Colors.transparent,
    child: Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _imageInvestedBadge(),
            _titleInvestedBadge(),
          ],
        ),
      ),
    ),
  );

  Card _reagentCard() => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50)
    ),
    color: Colors.transparent,
    child: Padding(
      padding: EdgeInsets.only(top: 10),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _imageReagentBadge(),
            _titleReagentBadge(),
          ],
        ),
      ),
    ),
  );

  Card _passionateCard() => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50)
    ),
    color: Colors.transparent,
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _imagePassionateBadge(),
            _titlePasionateBadge(),
          ],
        ),
      ),
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],//Colors.grey[850],
      body: Column(
        children: <Widget>[
          ClipPath(
            clipper: MyClipper(),
            child: Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/imgs/persian-art.jpg"),
                        fit: BoxFit.cover
                    ),
                  ),
                  child: Center(
                    child: Text("Trophées", style: TextStyle(fontSize: 30, color: Colors.white)),
                  ),
                ),
                Positioned(
                  top: 25,
                  left: 20,
                  child: SizedBox.fromSize(
                    size: Size(50, 50), // button width and height
                    child: ClipOval(
                      child: Material(
                        color: Colors.amber[700], // button color
                        child: InkWell(
                          splashColor: Colors.yellow, // splash color
                          onTap: () {
                            Navigator.push(
                              context, MaterialPageRoute(
                                builder: (BuildContext context) => MenuBoardScreen() )
                            );
                          }, // button pressed
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 200,
                height: 230,
                padding: EdgeInsets.all(0),
                child: _curiousCard(),
              ),
              Container(
                width: 200,
                height: 230,
                padding: EdgeInsets.all(0),
                child: _investedCard(),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 200,
                height: 230,
                padding: EdgeInsets.all(0),
                child: _reagentCard(),
              ),
              Container(
                width: 200,
                height: 230,
                padding: EdgeInsets.all(0),
                child: _passionateCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    createWave(size, path);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

createWave(Size size, Path path){
  path.lineTo(0, size.height);
  path.quadraticBezierTo(size.width/6, size.height - 80, size.width/2, size.height-40);
  path.quadraticBezierTo(3/4*size.width, size.height, size.width, size.height-60);
  path.lineTo(size.width, 0);
}

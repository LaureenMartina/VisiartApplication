import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:visiart/dashboard/menu.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/localization/AppLocalization.dart';

class AwardsListScreen extends StatefulWidget {
  @override
  _AwardsListScreenState createState() => _AwardsListScreenState();
}

class _AwardsListScreenState extends State<AwardsListScreen> {

  int _counterCurious = 0, _counterInvested = 0, _counterReagent = 0, _counterDrawing = 0;
  bool _isEnabledCurious = false, _isEnabledInvested = false, _isEnabledReagent = false, _isEnabledPassionate = false;

  @override
  void initState() {
    SharedPref().readBool("curiousBadgeEnabled").then((value) => {
        setState(() {
            _isEnabledCurious = value;
        })
    });
    SharedPref().readBool("investedBadgeEnabled").then((value) => {
        setState(() {
            _isEnabledInvested = value;
        })
    });
    SharedPref().readBool("reagentBadgeEnabled").then((value) => {
        setState(() {
            _isEnabledReagent = value;
        })
    });
    SharedPref().readBool("passionateBadgeEnabled").then((value) => {
        setState(() {
            _isEnabledPassionate = value;
        })
    });
    
    SharedPref().readInteger("counterInvested").then((value) => {
        setState(() {
          if(value == 99999) {
            _counterInvested = 0;
          } else {
            _counterInvested = value;
          }
        })
    });
    SharedPref().readInteger("counterReagent").then((value) => {
        setState(() {
          if(value == 99999) {
            _counterReagent = 0;
          } else {
            _counterReagent = value;
          }
        })
    });
    SharedPref().readInteger("counterDrawing").then((value) => {
        setState(() {
          if(value == 99999) {
            _counterDrawing = 0;
          } else {
            _counterDrawing = value;
          }
        })
    });

    _setCuriousImage();
    super.initState();
  }
  
  String _setCuriousImage() {
    String _imageBadge = "";
    if(_isEnabledCurious) {
      _counterCurious = 1;
      _imageBadge = "assets/imgs/curieux.png";
    }else{
      _imageBadge = "assets/imgs/coming-soon.png";
    }
    return _imageBadge;
  }

  String _setInvestedImage() {
    String _imageBadge = "";

    if(_counterInvested >= COUNTER_INVESTED) {
      SharedPref().saveBool("investedBadgeEnabled", true);
      _imageBadge = "assets/imgs/investi.png";
    }else{
      _imageBadge = "assets/imgs/coming-soon.png";
    }
    return _imageBadge;
  }

  String _setReagentImage() {
    String _imageBadge = "";

    if(_counterReagent >= COUNTER_REAGENT) {
      SharedPref().saveBool("reagentBadgeEnabled", true);
      _imageBadge = "assets/imgs/reactif.png";
    }else{
      _imageBadge = "assets/imgs/coming-soon.png";
    }
    return _imageBadge;
  }

  String _setPassionateImage() {
    String _imageBadge = "";

    if(_isEnabledCurious && _isEnabledInvested && _isEnabledReagent && (_counterDrawing >= COUNTER_DRAWING) ) {
      SharedPref().saveBool("passionateBadgeEnabled", true);
      _imageBadge = "assets/imgs/passionne.png";
    }else{
      _imageBadge = "assets/imgs/coming-soon.png";
    }
    return _imageBadge;
  }


  Padding _titleCuriousBadge() => Padding(
    padding: EdgeInsets.only(top: 10),
    child: Text(
      '$_counterCurious/$COUNTER_CURIOUS\n' + AppLocalizations.of(context).translate("awards_titleCurious"),
      maxLines: 3,
      softWrap: true,
      style: TextStyle(fontSize: 17.0),
      textAlign: TextAlign.center,
    ),
  );
  
  Padding _titleInvestedBadge() => Padding(
    padding: EdgeInsets.all(10),
    child: Text(
      '$_counterInvested/$COUNTER_INVESTED\n' + AppLocalizations.of(context).translate("awards_titleInvested"),
      maxLines: 3,
      softWrap: true,
      style: TextStyle(fontSize: 17.0),
      textAlign: TextAlign.center,
    ),
  );
  
  Padding _titleReagentBadge() => Padding(
    padding: EdgeInsets.only(top: 10),
    child: Text(
      '$_counterReagent/$COUNTER_REAGENT\n' + AppLocalizations.of(context).translate("awards_titleReagent"),
      maxLines: 3,
      softWrap: true,
      style: TextStyle(fontSize: 17.0),
      textAlign: TextAlign.center,
    ),
  );

  Padding _titlePasionateBadge() => Padding(
    padding: EdgeInsets.all(10),
    child: Text(
      '$_counterDrawing/$COUNTER_DRAWING\n' + AppLocalizations.of(context).translate("awards_titlePassionate"),
      maxLines: 3,
      softWrap: true,
      style: TextStyle(fontSize: 17.0),
      textAlign: TextAlign.center,
    ),
  );


  Flexible _imageCuriousBadge() => Flexible(
    child: Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
      backgroundColor: Color.fromRGBO(249, 248, 249, 1.0),
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
                    child: Text(AppLocalizations.of(context).translate("awards_title"), style: TextStyle(fontSize: 30, color: Colors.white)),
                  ),
                ),
                Positioned(
                  top: 25,
                  left: 20,
                  child: SizedBox.fromSize(
                    size: Size(50, 50), // button width and height
                    child: ClipOval(
                      child: Material(
                        color: Color.fromRGBO(82, 59, 92, 1.0), // button color
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
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => Detail(_setCuriousImage(), AppLocalizations.of(context).translate('awards_descriptionCurious')) ));
                },
                child: Container(
                  width: 185,
                  height: 230,
                  child: _curiousCard(),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => Detail(_setInvestedImage(), AppLocalizations.of(context).translate('awards_descriptionInvested')) ));
                },
                child: Container(
                  width: 185,
                  height: 230,
                  child: _investedCard(),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => Detail(_setReagentImage(), AppLocalizations.of(context).translate('awards_descriptionReagent')) ));
                },
                child: Container(
                  width: 185,
                  height: 230,
                  child: _reagentCard(),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => Detail(_setPassionateImage(), AppLocalizations.of(context).translate('awards_descriptionPassionate')) ));
                },
                child: Container(
                  width: 185,
                  height: 230,
                  child: _passionateCard(),
                ),
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

class Detail extends StatelessWidget {
  final String assetName;
  final String description;
  const Detail(this.assetName, this.description);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top:40),
        child: Column(
          children: [
            Center(
              child: Image.asset("${this.assetName}"),
            ),
            Padding(
              padding: EdgeInsets.only(top:25, left: 30, right: 30),
              child: Text(
                "${this.description}",
                maxLines: 5,
                softWrap: true,
                style: TextStyle(fontSize: 17.0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
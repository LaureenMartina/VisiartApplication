import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:progress_button/progress_button.dart';
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/models/Hobby.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/ModalAwards.dart';
import 'package:visiart/utils/AlertUtils.dart';

List<Hobby> nameChips = [];

class UserInterestsScreen extends StatefulWidget {
  @override
  _UserInterestsScreenState createState() => _UserInterestsScreenState();
}

class _UserInterestsScreenState extends State<UserInterestsScreen> {
  String titlePopup;
  String description;
  String button;
  final String navigateModalTo = 'dashboard';

  final divider = Divider(
    color: Colors.black38,
    indent: 30,
    endIndent: 30,
  );

  void _onSaveInterestsClicked() async {
    List<int> ids = List();
    nameChips
        .where((e) => e.isSelected)
        .forEach((e) {ids.add(e.id);});

    if (ids.length == 0) {
      showAlert(
          context, 
          AppLocalizations.of(context).translate('warning'), 
          AppLocalizations.of(context).translate('userInterests_selectOneHobby'), 
          AppLocalizations.of(context).translate('close'));
      return;
    }
    dynamic data = {
      'hobbies': [
        for (var i in ids){
          'id': i
        }
      ]
    };
    data = json.encode(data);
    http.put(
        API_USERS + "/${await SharedPref().readInteger("userId")}",
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await SharedPref().read("token")}'
        },
        body: data
    ).then((value) {
      if (value.statusCode == 200) {
        _setAwardsFirstConnexion();
        _showModal(context);
      } else {
      }
    });
  }

  void _setAwardsFirstConnexion() {
    SharedPref().saveInteger("counterInvested", 0);
    SharedPref().saveInteger("counterReagent", 0);
    SharedPref().saveInteger("counterDrawing", 0);
    _updateAwardsUser();
  }

  Future<void> _updateAwardsUser() async {
    var token = await SharedPref().read("token");
    var userId = await SharedPref().readInteger(API_USER_ID_KEY);

    final response = await http.put(API_USERS + "/" + userId.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, 
      body: jsonEncode({
        "Award": {
          'curiousBadge' : true,
          'investedBadge': false,
          'reagentBadge': false,
          'passionateBadge': false
        },
      })
    );

    if (response.statusCode == 200) {
        setState(() {});
    } else {
      throw Exception('Failed to load events from API');
    }
  }

  // Call to have the Popup Badge information
  void _showModal(BuildContext context) {
    ModalAwards _modalAwards = new ModalAwards(
        titlePopup, description, button, context, navigateModalTo);
    _modalAwards.getModal();
  }

  @override
  Widget build(BuildContext context) {
    titlePopup = AppLocalizations.of(context).translate('userInterests_congratulations');
    description = AppLocalizations.of(context).translate('userInterests_modalMessage');
    button = AppLocalizations.of(context).translate('userInterests_modalButton');

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
        brightness: Brightness.light,
        elevation: 2,
        title: Text(
          AppLocalizations.of(context).translate('userInterest_userInterest'),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              child: Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(AppLocalizations.of(context).translate('userInterest_tellUsWhatYouLike'),
                  style: TextStyle(
                      color: Color.fromRGBO(173, 165, 177, 1.0),
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5),
                  textAlign: TextAlign.center
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 40,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  AppLocalizations.of(context).translate('userInterest_select'),
                  style: TextStyle(
                    color: Color.fromRGBO(82, 59, 92, 1.0), fontSize: 15, letterSpacing: 1.2)
                  ),
              ),
            ),
          ),
          CreateFilterChip(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 30, right: 30, top: 10),
              child: ProgressButton(
                child: Text(
                  AppLocalizations.of(context).translate('save'),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                buttonState: ButtonState.normal,
                backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
                onPressed: () {
                  _onSaveInterestsClicked();
                },
                progressColor: Color.fromRGBO(82, 59, 92, 1.0),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}

class CreateFilterChip extends StatefulWidget {
  final String chipName;

  CreateFilterChip({Key key, this.chipName}) : super(key: key);

  @override
  _CreateFilterChipState createState() => _CreateFilterChipState();
}

class _CreateFilterChipState extends State<CreateFilterChip> {
  bool isSelected = false;

  void _getHobbies() async {
    http.get(API_HOBBIES, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await SharedPref().read("token")}'
    }).then((r) {
      if (r.statusCode == 200) {
        List res = jsonDecode(r.body);
        res.forEach((e) {
          nameChips.add(Hobby(id: e['id'], name: e['name']));
        });
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    _getHobbies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 250,
        child: Padding(
          padding: EdgeInsets.only(left: 15),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Wrap(
                children: [
                  for (var chip in nameChips)
                    Padding(
                        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: FilterChip(
                            label: Text(chip.name),
                            selectedColor: Color.fromRGBO(252, 233, 216, 1.0),
                            selected: chip.isSelected,
                            onSelected: (value) {
                              setState(() {
                                chip.isSelected = value;
                              });
                            }))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:progress_button/progress_button.dart';
import 'package:visiart/config/config.dart' as globals;
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/models/ModalAwards.dart';

class UserInterestsScreen extends StatefulWidget {
  @override
  _UserInterestsScreenState createState() => _UserInterestsScreenState();
}

class _UserInterestsScreenState extends State<UserInterestsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[200],
        brightness: Brightness.light,
        elevation: 2,
        title: Text(AppLocalizations.of(context).translate('userInterest_userInterest'),
          style: TextStyle(color: Colors.black87),),
      ),
      body: _bodyScreen(context),
      backgroundColor: Colors.grey[200],
    );
  }
}

Widget _bodyScreen(BuildContext context) {
  bool _switchValue = false; // Button Switch

  final String titlePopup = "Bravooo !!";
  final String description = "Votre 1er Trophée !\nDisponible depuis votre dashboard";
  final String button = "Compris 👍";
  final String navigateModalTo = "dashboard";


  final divider = Divider(
    color: Colors.black38,
    indent: 30,
    endIndent: 30,
  );

  List<String> nameChips = [
    AppLocalizations.of(context).translate("userInterest_museum"),
    AppLocalizations.of(context).translate("userInterest_exposition"),
    AppLocalizations.of(context).translate("userInterest_cineam"),
    AppLocalizations.of(context).translate("userInterest_painting"),
    AppLocalizations.of(context).translate("userInterest_atheleticEvent"),
    AppLocalizations.of(context).translate("userInterest_music"),
    AppLocalizations.of(context).translate("userInterest_gig"),
    AppLocalizations.of(context).translate("userInterest_dance"),
    AppLocalizations.of(context).translate("userInterest_modernArt"),
    AppLocalizations.of(context).translate("userInterest_Theater"),
    AppLocalizations.of(context).translate("userInterest_drawing"),
    AppLocalizations.of(context).translate("userInterest_design"),
    AppLocalizations.of(context).translate("userInterest_literature"),
    AppLocalizations.of(context).translate("userInterest_show"),
    AppLocalizations.of(context).translate("userInterest_photo")
  ];

  void _setAwardsFirstConnexion() {
    print(globals.curiousBadgeEnabled = true);
    globals.curiousBadgeEnabled = true;
  }

  // Call to have the Popup Badge information
  void _showModal(BuildContext context) {
    ModalAwards _modalAwards = new ModalAwards(titlePopup, description, button, context, navigateModalTo);
    Future<dynamic> modal = _modalAwards.getModal();
  }


  return CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(
        child: Container(
          height: 100,
          child: Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(AppLocalizations.of(context).translate('userInterest_tellUsWhatYouLike'),
                style: TextStyle(
                    color: Colors.deepOrange[200],
                    fontSize: 25,
                    letterSpacing: 2.5
                ),
                textAlign: TextAlign.center
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          height: 40,
          child: Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Text(AppLocalizations.of(context).translate('userInterest_select'),
                style: TextStyle(color: Colors.black87, fontSize: 14)
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          height: 250,
          child: Padding(
            padding: EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Wrap(
                  children: [
                    for (var name in nameChips)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: CreateFilterChip(chipName: name),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15, right: 40),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppLocalizations.of(context).translate('userInterest_move')),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Switch(
                  value: _switchValue,
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    //setState(() {
                    // TODO setState not working
                      _switchValue = value;
                      print(_switchValue);
                    //});
                  },
                ),
              )
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(left: 30, right: 30, top: 10),
          child: ProgressButton(
            child: Text(AppLocalizations.of(context).translate('userInterest_save'),
              style: TextStyle(color: Colors.black87, fontSize: 18),
            ),
            buttonState: ButtonState.normal,
            backgroundColor: Colors.deepOrange[200],
            onPressed: () {
              _setAwardsFirstConnexion();
              _showModal(context);
            },
            progressColor: Colors.deepOrange[300],
          ),
        ),
      ),
    ],
  );
}

class CreateFilterChip extends StatefulWidget {
  final String chipName;

  CreateFilterChip({Key key, this.chipName}) : super(key: key);

  @override
  _createFilterChipState createState() => _createFilterChipState();
}

class _createFilterChipState extends State<CreateFilterChip> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.chipName),
      selected: isSelected,
      selectedColor: Colors.green,
      onSelected: (value) {
        setState(() {
          isSelected = value;
        });
      },
    );
  }
}
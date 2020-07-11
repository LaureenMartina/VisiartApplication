import 'package:flutter/material.dart';
import 'package:visiart/localization/AppLocalization.dart';

class PrivacyPolicy extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    List<String> titles = [
      AppLocalizations.of(context).translate("rgpd_aboutUsTitle"),
      AppLocalizations.of(context).translate("rgpd_personnalDataTitle"),
      AppLocalizations.of(context).translate("rgpd_personnalDataTransmitionTitle"),
      AppLocalizations.of(context).translate("rgpd_persistanceDataTitle"),
      AppLocalizations.of(context).translate("rgpd_marketingOperationTitle")
    ];

    List<String> infos = [
      AppLocalizations.of(context).translate("rgpd_aboutUs"),
      AppLocalizations.of(context).translate("rgpd_personnalData"),
      AppLocalizations.of(context).translate("rgpd_personnalDataTransmition"),
      AppLocalizations.of(context).translate("rgpd_persistanceData"),
      AppLocalizations.of(context).translate("rgpd_marketingOperation")
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Colors.blueGrey[700],
            expandedHeight: 130.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppLocalizations.of(context).translate("rgpd_title")),
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 85,
                      width: 85,
                      margin: EdgeInsets.only(top: 16.0),
                      padding: EdgeInsets.only(left: 32.0, right: 32.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/icons/shield.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
            ),
            elevation: 10,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 25, bottom: 10),
                            child: Center(
                              child: Container(
                                child: Text(titles[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(82, 59, 92, 1.0)
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Text(infos[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 1,
                                wordSpacing: 1.2,
                                height: 1.5
                              ),
                            ),
                          ),
                          SizedBox(height: 40,),
                        ],
                      ),
                    ),
                  ],
                );
              },childCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
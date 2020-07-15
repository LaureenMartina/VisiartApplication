import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:visiart/config/SharedPref.dart';
import 'package:visiart/config/config.dart';
import 'package:visiart/localization/AppLocalization.dart';
import 'package:visiart/utils/AlertUtils.dart';
import 'package:visiart/utils/FormUtils.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountState createState() => new _AccountState();
}

class _AccountState extends State<AccountScreen> {
  final _nameController = TextEditingController();
  final _fNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _languageController = TextEditingController();

  final _nameFocus = FocusNode();
  final _fNameFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _languageFocus = FocusNode();

  void _getMyInfo() async {
    http.get(API_USERS_ME, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await SharedPref().read("token")}'
    }).then((r) {
      if (r.statusCode != 200) {
        showAlert(context, AppLocalizations.of(context).translate("account_error"), AppLocalizations.of(context).translate("account_infoError"), AppLocalizations.of(context).translate("account_back"), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            SystemNavigator.pop();
          }
        });
        return;
      } else if (r.statusCode == 200) {
        Map res = json.decode(r.body);
        _nameController.text = res['name'];
        _fNameController.text = res['firstname'];
        _usernameController.text = res['username'];
        _phoneController.text = res['phone'];
      }
    });
  }

  void _onClickSaveButton() async {
    if (_usernameController.text.isEmpty ||
        _fNameController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty) {
          showAlert(context, AppLocalizations.of(context).translate("warning"),
            AppLocalizations.of(context).translate("forms_warningFill"),
            AppLocalizations.of(context).translate("close"));
      return;
    }

    Map data = {
      'username': _usernameController.text.trim(),
      'name': _nameController.text.trim(),
      'firstname': _fNameController.text.trim(),
      'phone': _phoneController.text.trim()
    };

    http
        .put('$API_USERS/${await SharedPref().readInteger("userId")}',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${await SharedPref().read("token")}'
            },
            body: json.encode(data))
        .then((r) {
      if (r.statusCode == 200) {
        SharedPref().save("name", _nameController.text.trim());
        showAlert(context, AppLocalizations.of(context).translate("account_nice"), AppLocalizations.of(context).translate("account_infoSuccess"), AppLocalizations.of(context).translate("close"));
      } else {
        showAlert(context, ":(", AppLocalizations.of(context).translate("account_problem"), AppLocalizations.of(context).translate("close"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _getMyInfo();
    _languageController.text = window.locale.languageCode.toUpperCase();

    final nameField = Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        controller: _nameController,
        textInputAction: TextInputAction.next,
        focusNode: _nameFocus,
        onFieldSubmitted: (_) {
          fieldFocusChange(context, _nameFocus, _fNameFocus);
        },
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
        decoration: InputDecoration(
            icon: Icon(Icons.person),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            labelText: AppLocalizations.of(context).translate("account_name"),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );

    final fNameField = Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        controller: _fNameController,
        textInputAction: TextInputAction.next,
        focusNode: _fNameFocus,
        onFieldSubmitted: (_) {
          fieldFocusChange(context, _fNameFocus, _usernameFocus);
        },
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
        decoration: InputDecoration(
            icon: Icon(Icons.person),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            labelText: AppLocalizations.of(context).translate("account_firstname"),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );

    final usernamenameField = Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        controller: _usernameController,
        textInputAction: TextInputAction.next,
        focusNode: _usernameFocus,
        onFieldSubmitted: (_) {
          fieldFocusChange(context, _usernameFocus, _phoneFocus);
        },
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
        decoration: InputDecoration(
            icon: Icon(Icons.person),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            labelText: AppLocalizations.of(context).translate("account_username"),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );

    final phoneField = Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        controller: _phoneController,
        textInputAction: TextInputAction.done,
        focusNode: _phoneFocus,
        keyboardType: TextInputType.phone,
        onFieldSubmitted: (_) {
          _onClickSaveButton();
        },
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
        decoration: InputDecoration(
            icon: Icon(Icons.phone_android),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            labelText: AppLocalizations.of(context).translate("account_phone"),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );

    final languageField = Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        controller: _languageController,
        textInputAction: TextInputAction.done,
        focusNode: _languageFocus,
        keyboardType: TextInputType.phone,
        style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0),
        decoration: InputDecoration(
          icon: Icon(Icons.language),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          labelText: AppLocalizations.of(context).translate("account_language"),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      ),
    );

    final saveButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color.fromRGBO(82, 59, 92, 0.8),
      child: MaterialButton(
        onPressed: () {
          _onClickSaveButton();
        },
        child: Text(AppLocalizations.of(context).translate("account_save"),
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 18.0)
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(82, 59, 92, 1.0),
        title: Text(AppLocalizations.of(context).translate("account_title")),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          children: <Widget>[
            SizedBox(height: 40,),
            nameField,
            SizedBox(height: 10,),
            fNameField,
            SizedBox(height: 10,),
            usernamenameField,
            SizedBox(height: 10,),
            phoneField,
            SizedBox(height: 10,),
            languageField,
            SizedBox(height: 30,),
            saveButton,
          ],
        ),
      ),
    );
  }
}

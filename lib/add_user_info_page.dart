import 'dart:core';

import 'package:dart_wing_mobile/dart_wing/network/network_clients.dart';
import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';

import 'dart_wing/core/globals.dart';
import 'dart_wing/gui/widgets/base_colors.dart';
import 'dart_wing/gui/widgets/base_scaffold.dart';
import 'dart_wing/network/dart_wing/data/user.dart';

class AddUserInfoPage extends StatefulWidget {
  const AddUserInfoPage({super.key});

  @override
  _AddUserInfoPageState createState() => _AddUserInfoPageState();
}

class _AddUserInfoPageState extends State<AddUserInfoPage> {
  bool _loadingOverlayEnabled = false;
  final TextEditingController _firstNameController = TextEditingController(
      text: Globals.applicationInfo.username.split(" ").first);
  final TextEditingController _lastNameController = TextEditingController(
      text: Globals.applicationInfo.username.split(" ").last);
  final TextEditingController _emailController =
      TextEditingController(text: Globals.applicationInfo.userEmail);
  final TextEditingController _cellPhoneController = TextEditingController();
  String? _errorMessage;
  final _focusNode = FocusNode();

  _checkEmailAddress(String email) {
    if (EmailValidator.validate(email)) {
      _errorMessage = null;
    } else {
      _errorMessage = "Please enter a valid email address";
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode));
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      loadingOverlayEnabled: _loadingOverlayEnabled,
      appBar: AppBar(
        backgroundColor: BaseColors.lightBackgroundColor,
        title: Row(children: [
          Expanded(
              child: Text("Welcome to DartWing", textAlign: TextAlign.center)),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  "Let's finish setting up your account",
                  style: const TextStyle(fontSize: 16),
                )),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      //keyboardType: TextInputType.emailAddress,
                      controller: _firstNameController,
                      //style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "First Name",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "[Firstname]",
                        //hintStyle: const TextStyle(color: Colors.white24),
                        border: const OutlineInputBorder(),
                      ),
                    ))),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      //keyboardType: TextInputType.emailAddress,
                      controller: _lastNameController,
                      //style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "[Lastname]",
                        //hintStyle: const TextStyle(color: Colors.white24),
                        border: const OutlineInputBorder(),
                      ),
                    ))),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      //style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Personal Email",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "E-mail",
                        //hintStyle: const TextStyle(color: Colors.white24),
                        errorText: _errorMessage,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        _checkEmailAddress(_emailController.text);
                      },
                    ))),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: _cellPhoneController,
                      autocorrect: false,
                      inputFormatters: [
                        MaskedInputFormatter('+# #### ### ###')
                      ],
                      decoration: InputDecoration(
                        labelText: "Cell Phone",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "[Cell Phone]",
                        //hintStyle: const TextStyle(color: Colors.white24),
                        border: const OutlineInputBorder(),
                      ),
                    ))),
            Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[200],
                      minimumSize: const Size.fromHeight(60),
                    ),
                    onPressed: _errorMessage == null &&
                            _emailController.text.isNotEmpty &&
                            _firstNameController.text.isNotEmpty &&
                            _lastNameController.text.isNotEmpty
                        ? () {
                            User user = User();
                            user.firstName = _firstNameController.text;
                            user.lastName = _lastNameController.text;
                            user.email = _emailController.text;
                            user.phoneNumber = _cellPhoneController.text;
                            NetworkClients.dartWingApi
                                .createUser(user)
                                .then((user) {
                              Navigator.of(context).pop(user);
                            });
                          }
                        : null,
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          "Done",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    ]))),
          ],
        ),
      ),
    );
  }
}

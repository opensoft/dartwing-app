import 'dart:core';

import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'dart_wing/gui/widgets/base_colors.dart';
import 'dart_wing/gui/widgets/base_scaffold.dart';

class LoginWithEmailPage extends StatefulWidget {
  const LoginWithEmailPage({super.key});

  @override
  _LoginWithEmailPageState createState() => _LoginWithEmailPageState();
}

class _LoginWithEmailPageState extends State<LoginWithEmailPage> {
  bool _loadingOverlayEnabled = false;
  final TextEditingController _textController =
      TextEditingController(text: "Amanda Doe");
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  final _focusNode = FocusNode();
  String? _errorMessageCompanyName;

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
          Expanded(child: Text("Login", textAlign: TextAlign.center)),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
                child: SvgPicture.asset(
              'lib/dart_wing/images/dart_wing_icon.svg',
              alignment: Alignment.center,
              //width: 50,
            )),
            Flexible(
                child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              //style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                //labelStyle: const TextStyle(color: Colors.grey),
                hintText: "E-mail",
                //hintStyle: const TextStyle(color: Colors.white24),
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
              onChanged: (text) {
                _checkEmailAddress(_emailController.text);
              },
            )),
            Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[200],
                      minimumSize: const Size.fromHeight(60),
                    ),
                    onPressed: _errorMessage == null &&
                            _emailController.text.isNotEmpty
                        ? () {
                            // TODO: request OTP by email and went to next page
                            Navigator.of(context)
                                .pushNamed(DartWingAppsRouters.otpLoginPage);
                          }
                        : null,
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          "Login (or Signup)",
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

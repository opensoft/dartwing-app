import 'dart:core';

import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'dart_wing/gui/widgets/base_colors.dart';
import 'dart_wing/gui/widgets/base_scaffold.dart';

class OtpLoginPage extends StatefulWidget {
  const OtpLoginPage({super.key});

  @override
  _OtpLoginPageState createState() => _OtpLoginPageState();
}

class _OtpLoginPageState extends State<OtpLoginPage> {
  bool _loadingOverlayEnabled = false;
  final TextEditingController _textController = TextEditingController();
  String? _errorMessage;
  final _focusNode = FocusNode();
  final int _onpCodeLength = 6;

  _checkOtpCode(String code) {
    if (code.length == _onpCodeLength) {
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
              child:
                  Text("Verify Email to login", textAlign: TextAlign.center)),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
                child: SvgPicture.asset(
              'lib/dart_wing/images/email_icon.svg',
              alignment: Alignment.center,
              width: 250,
              height: 250,
            )),
            Flexible(
                child: TextFormField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              controller: _textController,
              maxLength: _onpCodeLength,
              //style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                //labelStyle: const TextStyle(color: Colors.grey),
                hintText: "OTP",
                //hintStyle: const TextStyle(color: Colors.white24),
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
              onChanged: (text) {
                _checkOtpCode(_textController.text);
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
                            _textController.text.isNotEmpty
                        ? () {
                            // TODO: check OTP and went to next page
                            Navigator.of(context)
                                .pushNamed(DartWingAppsRouters.addUserInfoPage);
                          }
                        : null,
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          "Continue",
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

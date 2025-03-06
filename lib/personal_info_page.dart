import 'dart:core';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';

import 'dart_wing/core/globals.dart';
import 'dart_wing/gui/widgets/base_colors.dart';
import 'dart_wing/gui/widgets/base_scaffold.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  bool _loadingOverlayEnabled = false;
  final TextEditingController _textController =
      TextEditingController(text: "Amanda Doe");
  final List<TextEditingController> _emailControllersList = [];
  final List<String?> _errorMessagesList = [];
  final _focusNode = FocusNode();
  String? _errorMessageCompanyName;

  final TextEditingController _firstNameController = TextEditingController(
      text: Globals.applicationInfo.username.split(" ").first);
  final TextEditingController _lastNameController = TextEditingController(
      text: Globals.applicationInfo.username.split(" ").last);
  final TextEditingController _emailController =
      TextEditingController(text: Globals.applicationInfo.userEmail);
  final TextEditingController _cellPhoneController = TextEditingController();
  String? _errorMessage;

  _checkEmailAddress(String email) {
    if (EmailValidator.validate(email)) {
      _errorMessage = null;
    } else {
      _errorMessage = "Enter valid email address";
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
          Expanded(child: Text("Personal info", textAlign: TextAlign.center)),
          InkWell(
            onTap: () {},
            child: Text(
              "Edit",
            ),
          )
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}

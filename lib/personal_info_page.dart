import 'dart:core';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

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

  void _addNewEmail() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _emailControllersList.add(TextEditingController());
      _errorMessagesList.add(null);
    });
  }

  void _removeEmail(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      if (index < _emailControllersList.length) {
        _emailControllersList.removeAt(index);
      }
      if (index < _errorMessagesList.length) {
        _errorMessagesList.removeAt(index);
      }
    });
  }

  List<String> _emails() {
    for (var error in _errorMessagesList) {
      if (error != null) {
        return [];
      }
    }
    List<String> emails = [];
    for (var controller in _emailControllersList) {
      if (controller.text != null && controller.text.isNotEmpty) {
        emails.add(controller.text);
      }
    }
    return emails;
  }

  _checkEmailAddress(int index) {
    if (EmailValidator.validate(_emailControllersList[index].text)) {
      _errorMessagesList[index] = null;
    } else {
      _errorMessagesList[index] = "Enter valid email address";
    }
    setState(() {});
  }

  @override
  void initState() {
    _addNewEmail();
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
          Expanded(child: Text("Account Info", textAlign: TextAlign.center)),
          InkWell(
            onTap: () {},
            child: Text(
              "Edit",
              style: TextStyle(
                  color: _errorMessageCompanyName == null &&
                          _textController.text.isNotEmpty &&
                          _emails().isNotEmpty
                      ? Colors.white
                      : Colors.grey),
            ),
          )
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(color: Colors.grey),
                counterStyle: const TextStyle(color: Colors.grey),
                hintText: "Enter user name",
                errorText: _errorMessageCompanyName,
                hintStyle: const TextStyle(color: Colors.white24),
                border: const OutlineInputBorder(),
              ),
              onTapAlwaysCalled: true,
              onChanged: (text) {},
            ),
          ],
        ),
      ),
    );
  }
}

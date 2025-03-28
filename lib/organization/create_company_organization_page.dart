import 'dart:core';

import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:flutter/material.dart';

import '../dart_wing/gui/notification.dart';
import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';
import '../dart_wing/network/dart_wing/dart_wing_api_helper.dart';
import '../dart_wing/network/dart_wing/data/organization.dart';
import '../dart_wing/network/network_clients.dart';

class CreateCompanyOrganizationPage extends StatefulWidget {
  const CreateCompanyOrganizationPage(
      {super.key, required this.descriptionOfOrganization});
  final String descriptionOfOrganization;

  @override
  _CreateCompanyOrganizationPageState createState() =>
      _CreateCompanyOrganizationPageState();
}

class _CreateCompanyOrganizationPageState
    extends State<CreateCompanyOrganizationPage> {
  bool _loadingOverlayEnabled = false;
  final TextEditingController _organizationNameController =
      TextEditingController();
  final TextEditingController _organizationAbbrController =
      TextEditingController();
  final _focusNode = FocusNode();
  Organization _organization = Organization();

  void _createCompany() {
    _organization.name = _organizationNameController.text;
    _organization.abbreviation = _organizationAbbrController.text;
    _organization.country = "United States";
    _organization.currency = "USD";
    _organization.companyType = OrganizationType.company;
    setState(() {
      _loadingOverlayEnabled = true;
    });
    NetworkClients.dartWingApi
        .createOrganization(_organization)
        .then((company) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      Navigator.of(context).pushNamed(DartWingAppsRouters.companyInfoPage,
          arguments: company.name);
    }).catchError((e) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      showWarningNotification(context, e.toString());
    });
  }

  @override
  void initState() {
    _organization.companyType = OrganizationType.company;
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
              child: Text(
                  widget.descriptionOfOrganization.toString().toUpperCase(),
                  textAlign: TextAlign.center)),
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
                      controller: _organizationNameController,
                      //style: const TextStyle(color: Colors.white),
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: "Company Name",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "Company Name",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: const OutlineInputBorder(),
                      ),
                    ))),
            Flexible(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      //keyboardType: TextInputType.emailAddress,
                      controller: _organizationAbbrController,
                      //style: const TextStyle(color: Colors.white),
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: "Abbreviation",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "Abbreviation",
                        hintStyle: const TextStyle(color: Colors.grey),
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
                    onPressed: _organizationNameController.text.isNotEmpty &&
                            _organizationAbbrController.text.isNotEmpty
                        ? () {
                            _createCompany();
                          }
                        : null,
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          "Create",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    ])))
          ],
        ),
      ),
    );
  }
}

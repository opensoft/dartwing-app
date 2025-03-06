import 'dart:core';

import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:flutter/material.dart';

import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';

class AddOrganizationPage extends StatefulWidget {
  const AddOrganizationPage({super.key});

  @override
  _AddOrganizationPageState createState() => _AddOrganizationPageState();
}

enum OrganizationType { company, family, club, nonprofit }

class _AddOrganizationPageState extends State<AddOrganizationPage> {
  bool _loadingOverlayEnabled = false;
  final TextEditingController _organizationNameController =
      TextEditingController();
  final _focusNode = FocusNode();
  OrganizationType? _selectedOrganization;

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
              child: Text("Add Organization", textAlign: TextAlign.center)),
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
                        labelText: "Organization name",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "Organization name",
                        //hintStyle: const TextStyle(color: Colors.white24),
                        border: const OutlineInputBorder(),
                      ),
                    ))),
            RadioListTile<OrganizationType>(
              title: Text('Company'),
              value: OrganizationType.company,
              groupValue: _selectedOrganization,
              onChanged: (OrganizationType? value) {
                setState(() {
                  _selectedOrganization = value;
                });
              },
            ),
            RadioListTile<OrganizationType>(
              title: Text('Family'),
              value: OrganizationType.family,
              groupValue: _selectedOrganization,
              onChanged: (OrganizationType? value) {
                setState(() {
                  _selectedOrganization = value;
                });
              },
            ),
            RadioListTile<OrganizationType>(
              title: Text('Club'),
              value: OrganizationType.club,
              groupValue: _selectedOrganization,
              onChanged: (OrganizationType? value) {
                setState(() {
                  _selectedOrganization = value;
                });
              },
            ),
            RadioListTile<OrganizationType>(
              title: Text('Nonprofit'),
              value: OrganizationType.nonprofit,
              groupValue: _selectedOrganization,
              onChanged: (OrganizationType? value) {
                setState(() {
                  _selectedOrganization = value;
                });
              },
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[200],
                      minimumSize: const Size.fromHeight(60),
                    ),
                    onPressed: _organizationNameController.text.isNotEmpty &&
                            _selectedOrganization != null
                        ? () {
                            if (_selectedOrganization ==
                                OrganizationType.company) {
                              Navigator.of(context).pushNamed(
                                  DartWingAppsRouters.companyOrganizationPage,
                                  arguments: _organizationNameController.text);
                            } else if (_selectedOrganization ==
                                OrganizationType.family) {
                              Navigator.of(context).pushNamed(
                                  DartWingAppsRouters.companyOrganizationPage,
                                  arguments: _organizationNameController.text);
                            } else if (_selectedOrganization ==
                                OrganizationType.club) {
                              Navigator.of(context).pushNamed(
                                  DartWingAppsRouters.companyOrganizationPage,
                                  arguments: _organizationNameController.text);
                            } else if (_selectedOrganization ==
                                OrganizationType.nonprofit) {
                              Navigator.of(context).pushNamed(
                                  DartWingAppsRouters.companyOrganizationPage,
                                  arguments: _organizationNameController.text);
                            }
                          }
                        : null,
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          "Add",
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

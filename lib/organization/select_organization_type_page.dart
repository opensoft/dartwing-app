import 'dart:core';

import 'package:dart_wing_mobile/dart_wing/gui/gui_helper.dart';
import 'package:dart_wing_mobile/dart_wing/network/dart_wing/data/organization.dart';
import 'package:dart_wing_mobile/dart_wing/network/network_clients.dart';
import 'package:dart_wing_mobile/dart_wing_apps_routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../dart_wing/gui/notification.dart';
import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';
import '../dart_wing/network/dart_wing/dart_wing_api_helper.dart';

class SelectOrganizationTypePage extends StatefulWidget {
  const SelectOrganizationTypePage({super.key});

  @override
  _SelectOrganizationTypePageState createState() =>
      _SelectOrganizationTypePageState();
}

class _SelectOrganizationTypePageState
    extends State<SelectOrganizationTypePage> {
  bool _loadingOverlayEnabled = false;
  final TextEditingController _organizationDescriptionController =
      TextEditingController();
  final _focusNode = FocusNode();
  OrganizationType? _selectedOrganizationType;

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
            RadioListTile<OrganizationType>(
              secondary: SvgPicture.asset(
                'lib/dart_wing/gui/images/company_icon.svg',
                alignment: Alignment.center,
                //width: 50,
              ),
              title:
                  Text(organizationInfoByType[OrganizationType.company]!.label),
              value: OrganizationType.company,
              groupValue: _selectedOrganizationType,
              onChanged: (OrganizationType? value) {
                setState(() {
                  _selectedOrganizationType = value;
                });
              },
            ),
            RadioListTile<OrganizationType>(
              secondary: SvgPicture.asset(
                'lib/dart_wing/gui/images/family_icon.svg',
                alignment: Alignment.center,
                //width: 50,
              ),
              title:
                  Text(organizationInfoByType[OrganizationType.family]!.label),
              value: OrganizationType.family,
              groupValue: _selectedOrganizationType,
              onChanged: (OrganizationType? value) {
                setState(() {
                  _selectedOrganizationType = value;
                });
              },
            ),
            RadioListTile<OrganizationType>(
              secondary: SvgPicture.asset(
                'lib/dart_wing/gui/images/club_icon.svg',
                alignment: Alignment.center,
                //width: 50,
              ),
              title: Text(organizationInfoByType[OrganizationType.club]!.label),
              value: OrganizationType.club,
              groupValue: _selectedOrganizationType,
              onChanged: (OrganizationType? value) {
                setState(() {
                  _selectedOrganizationType = value;
                });
              },
            ),
            RadioListTile<OrganizationType>(
              secondary: SvgPicture.asset(
                'lib/dart_wing/gui/images/nonprofit_icon.svg',
                alignment: Alignment.center,
                //width: 50,
              ),
              title: Text(
                  organizationInfoByType[OrganizationType.nonProfit]!.label),
              value: OrganizationType.nonProfit,
              groupValue: _selectedOrganizationType,
              onChanged: (OrganizationType? value) {
                setState(() {
                  _selectedOrganizationType = value;
                });
              },
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      //keyboardType: TextInputType.emailAddress,
                      controller: _organizationDescriptionController,
                      //style: const TextStyle(color: Colors.white),
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: "Description",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "Description",
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
                    onPressed: _selectedOrganizationType != null
                        ? () {
                            if (_selectedOrganizationType ==
                                OrganizationType.company) {
                              Navigator.of(context).pushNamed(
                                  DartWingAppsRouters
                                      .createCompanyOrganizationPage,
                                  arguments:
                                      _organizationDescriptionController.text);
                            } else if (_selectedOrganizationType ==
                                OrganizationType.family) {
                              Navigator.of(context).pushNamed(
                                  DartWingAppsRouters
                                      .createCompanyOrganizationPage,
                                  arguments:
                                      _organizationDescriptionController.text);
                            } else if (_selectedOrganizationType ==
                                OrganizationType.club) {
                              Navigator.of(context).pushNamed(
                                  DartWingAppsRouters
                                      .createCompanyOrganizationPage,
                                  arguments:
                                      _organizationDescriptionController.text);
                            } else if (_selectedOrganizationType ==
                                OrganizationType.nonProfit) {
                              Navigator.of(context).pushNamed(
                                  DartWingAppsRouters
                                      .createCompanyOrganizationPage,
                                  arguments:
                                      _organizationDescriptionController.text);
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

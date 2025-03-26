import 'dart:core';

import 'package:dart_wing_mobile/dart_wing/network/dart_wing/data/organization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../dart_wing/gui/notification.dart';
import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';
import '../dart_wing/network/network_clients.dart';
import '../dart_wing_apps_routers.dart';

class CompanyInfoPage extends StatefulWidget {
  const CompanyInfoPage({super.key, required this.companyName});
  final String companyName;

  @override
  _CompanyInfoPageState createState() => _CompanyInfoPageState();
}

class _CompanyInfoPageState extends State<CompanyInfoPage> {
  bool _loadingOverlayEnabled = false;
  final _focusNode = FocusNode();

  Organization _company = Organization();

  void _fetchOrganization() {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    NetworkClients.dartWingApi
        .fetchOrganization(widget.companyName)
        .then((company) {
      setState(() {
        _company = company;
        _loadingOverlayEnabled = false;
      });
    }).catchError((e) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      showWarningNotification(context, e.toString());
    });
  }

  @override
  void initState() {
    _fetchOrganization();
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
          Expanded(child: Text("Company", textAlign: TextAlign.center)),
        ]),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                    ),
                    child: InkWell(
                        onTap: () {},
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(children: [
                              Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: SvgPicture.asset(
                                    'lib/dart_wing/gui/images/company_icon.svg',
                                    alignment: Alignment.center,
                                    //width: 50,
                                  )),
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.companyName,
                                  style: const TextStyle(fontSize: 19),
                                ),
                              )),
                              Icon(Icons.navigate_next)
                            ]))))),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                    ),
                    child: InkWell(
                        onTap: () {},
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(children: [
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "All Contacts",
                                  style: const TextStyle(fontSize: 19),
                                ),
                              )),
                              Icon(Icons.navigate_next)
                            ]))))),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                    ),
                    child: InkWell(
                        onTap: () {},
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(children: [
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "All Departments",
                                  style: const TextStyle(fontSize: 19),
                                ),
                              )),
                              Icon(Icons.navigate_next)
                            ]))))),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                    ),
                    child: InkWell(
                        onTap: () {},
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(children: [
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Legal",
                                  style: const TextStyle(fontSize: 19),
                                ),
                              )),
                              Icon(Icons.navigate_next)
                            ]))))),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                    ),
                    child: InkWell(
                        onTap: () {},
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(children: [
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Industry",
                                  style: const TextStyle(fontSize: 19),
                                ),
                              )),
                              Icon(Icons.navigate_next)
                            ]))))),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius:
                          BorderRadius.circular(8), // Optional rounded corners
                    ),
                    child: InkWell(
                        onTap: () {},
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(children: [
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Tax",
                                  style: const TextStyle(fontSize: 19),
                                ),
                              )),
                              Icon(Icons.navigate_next)
                            ]))))),
            Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius:
                      BorderRadius.circular(8), // Optional rounded corners
                ),
                child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(DartWingAppsRouters.documentRepositoryPage, arguments: widget.companyName);
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(children: [
                          Expanded(
                              child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Document Repository",
                              style: const TextStyle(fontSize: 19),
                            ),
                          )),
                          Icon(Icons.navigate_next)
                        ])))),
          ])),
    );
  }
}

import 'dart:core';

import 'package:dart_wing_mobile/dart_wing/network/dart_wing/data/organization.dart';
import 'package:flutter/material.dart';

import '../dart_wing/gui/notification.dart';
import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';
import '../dart_wing/network/network_clients.dart';
import '../dart_wing_apps_routers.dart';

class OrganizationsListPage extends StatefulWidget {
  const OrganizationsListPage({super.key});

  @override
  _OrganizationsListPageState createState() => _OrganizationsListPageState();
}

class _OrganizationsListPageState extends State<OrganizationsListPage> {
  bool _loadingOverlayEnabled = false;
  final _focusNode = FocusNode();

  List<String> _organizations = [];

  void _fetchOrganizations() {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    NetworkClients.dartWingApi.fetchOrganizations().then((organizations) {
      setState(() {
        _organizations = organizations;
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
    _fetchOrganizations();
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
          Expanded(child: Text("Organizations", textAlign: TextAlign.center)),
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(DartWingAppsRouters.selectOrganizationTypePage);
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Add",
                      style: TextStyle(fontSize: 16),
                    ))),
          )
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: _organizations.length,
                  separatorBuilder: (context, index) => const Divider(
                        indent: 8,
                        color: Colors.grey,
                      ),
                  itemBuilder: (BuildContext context, int i) {
                    return Container(
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(
                              8), // Optional rounded corners
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
                                      _organizations[i],
                                      style: const TextStyle(fontSize: 19),
                                    ),
                                  )),
                                  Icon(Icons.navigate_next)
                                ]))));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

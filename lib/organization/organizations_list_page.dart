import 'dart:core';

import 'package:flutter/material.dart';

import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';
import '../dart_wing_apps_routers.dart';

class OrganizationsListPage extends StatefulWidget {
  const OrganizationsListPage({super.key});

  @override
  _OrganizationsListPageState createState() => _OrganizationsListPageState();
}

class _OrganizationsListPageState extends State<OrganizationsListPage> {
  bool _loadingOverlayEnabled = false;
  final _focusNode = FocusNode();

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
          children: [],
        ),
      ),
    );
  }
}

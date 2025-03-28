import 'dart:core';

import 'package:dart_wing_mobile/dart_wing/network/dart_wing/data/organization.dart';
import 'package:flutter/material.dart';

import '../dart_wing/gui/notification.dart';
import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';
import '../dart_wing/network/network_clients.dart';
import '../dart_wing_apps_routers.dart';

class DocumentRepositoryPage extends StatefulWidget {
  const DocumentRepositoryPage({super.key, required this.companyName});
  final String companyName;

  @override
  _DocumentRepositoryPageState createState() => _DocumentRepositoryPageState();
}

class _DocumentRepositoryPageState extends State<DocumentRepositoryPage> {
  bool _loadingOverlayEnabled = false;
  final _focusNode = FocusNode();

  Organization _company = Organization();
  final TextEditingController _folderPathController = TextEditingController();

  void _fetchOrganization() {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    NetworkClients.dartWingApi
        .fetchOrganization(widget.companyName)
        .then((company) {
      setState(() {
        _company = company;
        _folderPathController.text =
            company.microsoftSharepointFolderPath == null
                ? ""
                : company.microsoftSharepointFolderPath.toString();
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
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      loadingOverlayEnabled: _loadingOverlayEnabled,
      appBar: AppBar(
        backgroundColor: BaseColors.lightBackgroundColor,
        title: Row(children: [
          Expanded(
              child: Text("Document Repository", textAlign: TextAlign.center)),
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(DartWingAppsRouters.chooseDocumentRepositoryPage,
                      arguments: widget.companyName)
                  .then((_) {
                _fetchOrganization();
              });
            },
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Select",
                      style: TextStyle(fontSize: 16),
                    ))),
          )
        ]),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  readOnly: true,
                  //keyboardType: TextInputType.emailAddress,
                  controller: _folderPathController,
                  //style: const TextStyle(color: Colors.white),
                  onChanged: (_) {
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: _folderPathController.text.isEmpty
                        ? "Please select folder"
                        : "Folder Path",
                    //labelStyle: const TextStyle(color: Colors.grey),
                    hintText: "Please select folder",
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(),
                  ),
                )),
          ])),
    );
  }
}

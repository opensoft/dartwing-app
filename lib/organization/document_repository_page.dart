import 'dart:core';

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

  List<String> _documentRepositoryList = [];

  void _fetchDocumentRepositoryList() {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    NetworkClients.dartWingApi
        .fetchOrganizations()
        .then((documentRepositoryList) {
      setState(() {
        _documentRepositoryList = documentRepositoryList;
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
    //_fetchDocumentRepositoryList();
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
              Navigator.of(context).pushNamed(DartWingAppsRouters.chooseDocumentRepositoryPage, arguments: widget.companyName);
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
                  itemCount: _documentRepositoryList.length,
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
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                child: Row(children: [
                                  Expanded(
                                      child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Link to document repository",
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

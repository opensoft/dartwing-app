import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:sidebarx/sidebarx.dart';
import 'package:upgrader/upgrader.dart';

import 'dart_wing/gui/dialogs.dart';
import 'dart_wing/gui/widgets/base_colors.dart';
import 'dart_wing/gui/widgets/base_scaffold.dart';
import 'dart_wing/network/network_clients.dart';
import 'dart_wing_apps_routers.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.pageTitle}) : super(key: key);

  String pageTitle = '';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _isPressedIndex;
  bool _loadingOverlayEnabled = false;

  List<Widget> _tabs() {
    return const [
      Tab(
        text: "Home",
        icon: Icon(Icons.home),
      ),
      Tab(
        text: "Scanner",
        icon: Icon(Icons.document_scanner),
      ),
      Tab(
        text: "Settings",
        icon: Icon(Icons.settings),
      ),
      Tab(
        text: "Notif",
        icon: Icon(Icons.notifications),
      ),
    ];
  }

  Widget _bottomTabMenu() {
    return Container(
      color: BaseColors.lightBackgroundColor,
      child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(5.0),
          indicatorColor: Colors.blue,
          //labelStyle: TextStyle(fontSize: 12),
          tabs: _tabs()),
    );
  }

  Widget _appsTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[],
    );
  }

  _baseTab() {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              color: Colors.blueGrey,
            )));
  }

  Widget _scannerTab() {
    return _baseTab();
  }

  Widget _settingsTab() {
    return _baseTab();
  }

  Widget _notificationsTab() {
    return _baseTab();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: DefaultTabController(
        length: _tabs().length,
        child: BaseScaffold(
          loadingOverlayEnabled: _loadingOverlayEnabled,
          canPop: false,
          pageTitle: widget.pageTitle,
          defaultAppMenuEnabled: true,
          onPostLogout: () {},
          bottomNavigatorBar: _bottomTabMenu(),
          additionalSidebarXItems: [
            SidebarXItem(
                icon: Icons.account_circle_outlined,
                label: 'Personal Info',
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(DartWingAppsRouters.personalInfoPage);
                }),
            SidebarXItem(
                icon: Icons.highlight_remove,
                label: 'Organizations',
                onTap: () {}),
          ],
          onBarcodeFetched: (barcode) {},
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TabBarView(
                children: [
                  _appsTab(),
                  _scannerTab(),
                  _settingsTab(),
                  _notificationsTab()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:core';

import 'package:dart_wing_mobile/dart_wing/network/paper_trail.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dart_wing/gui/notification.dart';
import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';
import '../dart_wing/network/dart_wing/data/provider.dart';
import '../dart_wing/network/network_clients.dart';
import '../dart_wing_apps_routers.dart';

class ChooseDocumentRepositoryPage extends StatefulWidget {
  const ChooseDocumentRepositoryPage({super.key, required this.companyName});
  final String companyName;

  @override
  _ChooseDocumentRepositoryPageState createState() =>
      _ChooseDocumentRepositoryPageState();
}

class _ChooseDocumentRepositoryPageState
    extends State<ChooseDocumentRepositoryPage> {
  bool _loadingOverlayEnabled = false;

  List<Provider> _providers = [];
  Provider _currentProvider = Provider();

  void _fetchCompanyProviders() {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    NetworkClients.dartWingApi
        .fetchOrganizationProviders(widget.companyName)
        .then((providers) {
      if (_currentProvider.name.isEmpty) {
        _currentProvider = Provider();
      }
      providers.insert(0, _currentProvider);
      setState(() {
        _providers = providers;
        _loadingOverlayEnabled = false;
      });
    }).catchError((e) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      showWarningNotification(context, e.toString());
    });
  }

  void _fetchFolders() {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    NetworkClients.dartWingApi
        .fetchFolders(_currentProvider.name, '', widget.companyName)
        .then((folderResponse) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      if (folderResponse.redirectUrl != null &&
          folderResponse.redirectUrl!.isNotEmpty) {
        Uri uri = Uri.parse(folderResponse.redirectUrl!);
        //uri.queryParameters['redirect_uri'] = "https://qa.keycloak.tech-corps.com/realms/master/broker/google/endpoint";
        PaperTrailClient.sendInfoMessageToPaperTrail(uri.toString());
        launchUrl(uri);
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      showWarningNotification(context, e.toString());
    });
  }

  @override
  void initState() {
    _providers.add(_currentProvider);
    _fetchCompanyProviders();
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
              child: Text("Choose Document Repository",
                  textAlign: TextAlign.center)),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DropdownButtonFormField<Provider>(
                  isExpanded: true,
                  alignment: AlignmentDirectional.center,
                  value: _currentProvider,
                  icon: const Icon(Icons.arrow_downward),
                  iconEnabledColor: Colors.white,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black, fontSize: 22),
                  dropdownColor: BaseColors.lightBackgroundColor,
                  decoration: const InputDecoration(
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  onChanged: (Provider? provider) {
                    setState(() {
                      _currentProvider = provider!;
                    });
                    _fetchFolders();
                  },
                  items: _providers
                      .map<DropdownMenuItem<Provider>>((Provider provider) {
                    return DropdownMenuItem<Provider>(
                      value: provider,
                      child: Center(
                        child: Text(
                          provider.name,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

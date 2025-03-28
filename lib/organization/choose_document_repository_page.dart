import 'dart:core';

import 'package:dart_wing_mobile/dart_wing/network/paper_trail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dart_wing/gui/dialogs.dart';
import '../dart_wing/gui/notification.dart';
import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';
import '../dart_wing/network/dart_wing/data/folder.dart';
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

  List<Folder> _folders = [];

  Folder _selectedFolder = Folder();

  final TreeController _treeController =
      TreeController(allNodesExpanded: false);

  Future _saveFolderForDocumentRepository() {
    String _selectedFolderPath = _selectedFolder.name;
    Folder currentFolder = _selectedFolder;
    while (true) {
      List<Folder> parentFolders = _folders.where((folder) {
        return folder.id == currentFolder.parentId;
      }).toList();
      if (parentFolders.isEmpty) {
        break;
      }
      currentFolder = parentFolders.first;
      _selectedFolderPath = "${currentFolder.name}/$_selectedFolderPath";
    }

    return Dialogs.showInfoDialog(
            context, "Do you want to select\n$_selectedFolderPath ?",
            titleText: "Select folder",
            okButtonText: "Select",
            cancelButtonText: "Cancel")
        .then((result) {
      if (result == null) {
        return;
      }
      setState(() {
        _loadingOverlayEnabled = true;
      });
      NetworkClients.dartWingApi
          .saveFolderPath(_currentProvider.alias.toString(),
              _selectedFolderPath, widget.companyName)
          .then((_) {
        setState(() {
          _loadingOverlayEnabled = false;
        });
        Navigator.of(context).pop();
      }).catchError((e) {
        setState(() {
          _loadingOverlayEnabled = false;
        });
        showWarningNotification(context, e.toString());
      });
    });
  }

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
      //providers.insert(0, _currentProvider);
      setState(() {
        _loadingOverlayEnabled = false;
        _providers = providers;
        _setProvider(providers.first);
      });
    }).catchError((e) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      showWarningNotification(context, e.toString());
    });
  }

  Future _fetchFolders({String folderName = ''}) {
    setState(() {
      _loadingOverlayEnabled = true;
    });
    return NetworkClients.dartWingApi
        .fetchFolders(_currentProvider.alias.toString(), widget.companyName)
        .then((folderResponse) {
      _folders = folderResponse.folders!;
      setState(() {
        _loadingOverlayEnabled = false;
      });

      if (folderResponse.redirectUrl != null &&
          folderResponse.redirectUrl!.isNotEmpty) {
        Uri uri = Uri.parse(folderResponse.redirectUrl!);

        final updatedQueryParams =
            Map<String, String>.from(uri.queryParameters);
        updatedQueryParams['client_id'] = 'dartwingmobile';
        updatedQueryParams['redirect_uri'] =
            'com.opensoft.dartwing://login-callback';
        Uri updatedUri = uri.replace(
          queryParameters: updatedQueryParams,
        );

        //uri.queryParameters['redirect_uri'] =
        //    "сom.opensoft.dartwing://login-callback";
        //uri.queryParameters['client_id'] = "dartwingmobile";
        PaperTrailClient.sendInfoMessageToPaperTrail(updatedUri.toString());
        launchUrl(updatedUri);
      }
    }).catchError((e) {
      setState(() {
        _loadingOverlayEnabled = false;
      });
      showWarningNotification(context, e.toString());
    });
  }

  List<TreeNode> toTreeNodes({String? parentId}) {
    List<Folder> rootFolders = _folders.where((folder) {
      return folder.parentId == parentId;
    }).toList();

    List<TreeNode> nodes = [];
    for (var folder in rootFolders) {
      nodes.add(TreeNode(
          content: treeNodeWidget(folder),
          children: toTreeNodes(parentId: folder.id)));
    }

    return nodes;
  }

  Widget treeNodeWidget(Folder folder) {
    bool isSelected = _selectedFolder.id == folder.id;
    return Container(
        decoration: isSelected
            ? BoxDecoration(
                color: isSelected ? Colors.grey : null,
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius:
                    BorderRadius.circular(8), // Optional rounded corners
              )
            : null,
        child: InkWell(
            onTap: () {
              if (folder.canBeSelected) {
                setState(() {
                  _selectedFolder = folder;
                });
              }
            },
            child: Padding(
                padding: const EdgeInsets.all(5), child: Text(folder.name))));
  }

  void _setProvider(Provider provider) {
    bool fetchFoldersNeeded = false;
    if (_currentProvider.alias != provider.alias) {
      fetchFoldersNeeded = true;
    }
    setState(() {
      _currentProvider = provider;
    });
    if (fetchFoldersNeeded) {
      _fetchFolders();
    }
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButtonFormField<Provider>(
                isExpanded: true,
                alignment: AlignmentDirectional.center,
                value: _currentProvider,
                icon: const Icon(Icons.arrow_downward),
                iconEnabledColor: Colors.white,
                elevation: 16,
                style: const TextStyle(color: Colors.black, fontSize: 22),
                //dropdownColor: BaseColors.lightBackgroundColor,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.black),
                ),
                onChanged: (Provider? provider) {
                  _setProvider(provider!);
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
            Expanded(
                child: SingleChildScrollView(
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: TreeView(
                          nodes: toTreeNodes(),
                          treeController: _treeController,
                        )))),
            Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[200],
                      minimumSize: const Size.fromHeight(60),
                    ),
                    onPressed: _selectedFolder.name.isNotEmpty
                        ? () {
                            _saveFolderForDocumentRepository();
                          }
                        : null,
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          "Select",
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

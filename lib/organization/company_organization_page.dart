import 'dart:core';

import 'package:flutter/material.dart';

import '../dart_wing/gui/widgets/base_colors.dart';
import '../dart_wing/gui/widgets/base_scaffold.dart';

class CompanyOrganizationPage extends StatefulWidget {
  const CompanyOrganizationPage({super.key, required this.organizationName});
  final String organizationName;

  @override
  _CompanyOrganizationPageState createState() =>
      _CompanyOrganizationPageState();
}

enum OrganizationType { company, family, club, nonprofit }

class _CompanyOrganizationPageState extends State<CompanyOrganizationPage> {
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
              child:
                  Text(widget.organizationName, textAlign: TextAlign.center)),
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {},
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Edit",
                      style: TextStyle(fontSize: 16),
                    ))),
          )
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
                      decoration: InputDecoration(
                        labelText: "Organization type",
                        //labelStyle: const TextStyle(color: Colors.grey),
                        hintText: "Organization type",
                        //hintStyle: const TextStyle(color: Colors.white24),
                        border: const OutlineInputBorder(),
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}

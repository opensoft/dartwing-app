import 'dart:io';

import 'package:dart_wing_mobile/add_user_info_page.dart';
import 'package:dart_wing_mobile/dart_wing/gui/data/organization_info.dart';
import 'package:dart_wing_mobile/dart_wing/network/dart_wing/dart_wing_api_helper.dart';
import 'package:dart_wing_mobile/document_picker_page.dart';
import 'package:dart_wing_mobile/login_with_email_page.dart';
import 'package:dart_wing_mobile/organization/document_repository_page.dart';
import 'package:dart_wing_mobile/personal_info_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart_wing/core/globals.dart';
import 'dart_wing/gui/base_apps_routers.dart';
import 'dart_wing/network/paper_trail.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'organization/choose_document_repository_page.dart';
import 'organization/company_info_page.dart';
import 'organization/select_organization_type_page.dart';
import 'organization/create_company_organization_page.dart';
import 'organization/organizations_list_page.dart';
import 'otp_login_page.dart';

class DartWingAppsRouters extends BaseAppsRouters {
  static const String loginPage = 'loginPage';
  static const String homePage = 'homePage';
  static const String personalInfoPage = 'personalInfoPage';

  static const String loginWithEmailPage = 'loginWithEmailPage';
  static const String otpLoginPage = 'otpLoginPage';
  static const String addUserInfoPage = 'addUserInfoPage';

  static const String organizationsListPage = 'organizationsListPage';
  static const String selectOrganizationTypePage = 'selectOrganizationTypePage';
  static const String createCompanyOrganizationPage =
      'createCompanyOrganizationPage';
  static const String companyInfoPage = "companyInfoPage";
  static const String documentRepositoryPage = "documentRepositoryPage";
  static const String chooseDocumentRepositoryPage =
      "chooseDocumentRepositoryPage";
  static const String documentPickerPage = "documentPickerPage";

  @override
  static Future<dynamic> showScannerPage(BuildContext context, String pageTitle,
      {bool manualInputAllowed = true}) {
    return BaseAppsRouters.showScannerPage(context, pageTitle,
        manualInputAllowed: manualInputAllowed);
  }

  @override
  Route<dynamic> generateRouters(RouteSettings settings) {
    PaperTrailClient.sendInfoMessageToPaperTrail(
        "App version: ${Globals.applicationInfo.version} ${kIsWeb ? "WEB" : Platform.operatingSystem.toUpperCase()}, Page: ${settings.name}${settings.arguments != null && settings.arguments.toString().length < 200 ? ", arguments: ${settings.arguments}" : ""}");
    switch (settings.name) {
      case loginPage:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case homePage:
        return MaterialPageRoute(
            builder: (_) => HomePage(pageTitle: settings.arguments.toString()));
      case personalInfoPage:
        return MaterialPageRoute(builder: (_) => const PersonalInfoPage());
      case loginWithEmailPage:
        return MaterialPageRoute(builder: (_) => const LoginWithEmailPage());
      case otpLoginPage:
        return MaterialPageRoute(builder: (_) => const OtpLoginPage());
      case addUserInfoPage:
        return MaterialPageRoute(builder: (_) => const AddUserInfoPage());
      case organizationsListPage:
        return MaterialPageRoute(builder: (_) => const OrganizationsListPage());
      case selectOrganizationTypePage:
        return MaterialPageRoute(
            builder: (_) => const SelectOrganizationTypePage());
      case createCompanyOrganizationPage:
        return MaterialPageRoute(
            builder: (_) => CreateCompanyOrganizationPage(
                  descriptionOfOrganization: settings.arguments.toString(),
                ));
      case companyInfoPage:
        return MaterialPageRoute(
            builder: (_) => CompanyInfoPage(
                  companyName: settings.arguments.toString(),
                ));
      case documentRepositoryPage:
        return MaterialPageRoute(
            builder: (_) => DocumentRepositoryPage(
                companyName: settings.arguments.toString()));
      case chooseDocumentRepositoryPage:
        return MaterialPageRoute(
            builder: (_) => ChooseDocumentRepositoryPage(
                companyName: settings.arguments.toString()));
      case documentPickerPage:
        return MaterialPageRoute(builder: (_) => const DocumentPickerPage());
      default:
        return super.generateRouters(settings);
    }
  }
}

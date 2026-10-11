
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/business_model.dart';

class BusinessStorageService {
  static const String _businessKey = 'business_profile';

  static Future<BusinessModel?> getBusiness() async {
    final prefs = await SharedPreferences.getInstance();

    final businessJson = prefs.getString(_businessKey);

    if (businessJson == null || businessJson.isEmpty) {
      return null;
    }

    final Map<String, dynamic> json = jsonDecode(businessJson);

    return BusinessModel.fromJson(json);
  }

  static Future<void> saveBusiness(
      BusinessModel business,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final businessJson = jsonEncode(business.toJson());

    await prefs.setString(_businessKey, businessJson);
  }

  static Future<String> saveLogo(File logoFile) async {
    final directory = await getApplicationDocumentsDirectory();

    final logoDirectory = Directory(
      '${directory.path}/business_logo',
    );

    if (!await logoDirectory.exists()) {
      await logoDirectory.create(recursive: true);
    }

    final extension = logoFile.path.contains('.')
        ? logoFile.path.split('.').last
        : 'png';

    final savedLogo = File(
      '${logoDirectory.path}/business_logo.$extension',
    );

    if (await savedLogo.exists()) {
      await savedLogo.delete();
    }

    await logoFile.copy(savedLogo.path);

    return savedLogo.path;
  }

  static Future<void> clearBusiness() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_businessKey);
  }
}
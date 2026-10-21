import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/dashboard_content.dart';

class DashboardRepository {
  Future<DashboardContent> load() async {
    final raw = await rootBundle.loadString(
      'assets/data/dashboard_content.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return DashboardContent.fromJson(json);
  }
}

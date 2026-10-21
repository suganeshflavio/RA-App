import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}

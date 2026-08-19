import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get publishableKey => dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
  static String get secretKey => dotenv.env['SUPABASE_SECRET_KEY'] ?? '';

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}

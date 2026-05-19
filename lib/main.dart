import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/welcome_screen.dart';
import 'services/gemini_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final String supabaseUrl = (dotenv.env['SUPABASE_URL'] ?? '').trim();
  final String supabaseAnonKey = (dotenv.env['SUPABASE_ANON_KEY'] ?? '').trim();
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError('SUPABASE_URL 또는 SUPABASE_ANON_KEY가 .env에 없습니다. .env.example을 참고해 설정하세요.');
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const BurnItApp());
}

class BurnItApp extends StatelessWidget {
  const BurnItApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = GoogleFonts.notoSansKrTextTheme(
      ThemeData.light().textTheme,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '소각장 Burn It',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF7A9A8),
          brightness: Brightness.light,
        ),
        textTheme: textTheme.apply(
          bodyColor: const Color(0xFF333333),
          displayColor: const Color(0xFF333333),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFA),
          foregroundColor: Color(0xFF333333),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: WelcomeScreen(
        storageService: StorageService(),
        geminiService: GeminiService(),
      ),
    );
  }
}

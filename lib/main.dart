import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/hotel_provider.dart';
import 'providers/smart_room_provider.dart';
import 'screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => SmartRoomProvider()),
      ],
      child: const OpheliaApp(),
    ),
  );
}

class OpheliaApp extends StatelessWidget {
  const OpheliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ophelia Hotels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cream,
        primaryColor: AppColors.navy,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
        textTheme: GoogleFonts.cormorantGaramondTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.cream,
          elevation: 0,
        ),
      ),
      home: const MainWrapper(),
    );
  }
}

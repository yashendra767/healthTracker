import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:track_records_assignment/theme/app_theme.dart';
import 'app/bindings/auth_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TrackRecordsApp());
}

class TrackRecordsApp extends StatelessWidget {
  const TrackRecordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Health Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      //loggedin user
      initialRoute: AppRoutes.Splash,
      getPages: AppPages.pages,

      initialBinding: AuthBinding(),
    );
  }
}
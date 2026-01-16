import 'package:flutter/material.dart';
import 'package:mystagepass_admin/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'utils/colors.dart';
import 'providers/user_provider.dart';
import 'providers/performer_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => PerformerProvider()),
      ],

      child: const MyStagePassAdmin(),
    ),
  );
}

class MyStagePassAdmin extends StatelessWidget {
  const MyStagePassAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyStage Pass Admin',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
      ),

      home: const LoginScreen(),
    );
  }
}

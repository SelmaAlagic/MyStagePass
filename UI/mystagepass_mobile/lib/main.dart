import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/providers/customer_provider.dart';
import 'package:mystagepass_mobile/providers/notification_provider.dart';
import 'package:mystagepass_mobile/providers/performer_provider.dart';
import 'package:mystagepass_mobile/providers/genre_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'utils/colors_helpers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PerformerProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
      ],
      child: const MyStagePass(),
    ),
  );
}

class MyStagePass extends StatelessWidget {
  const MyStagePass({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyStagePass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

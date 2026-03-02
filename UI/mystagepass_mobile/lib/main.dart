import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/providers/customer_provider.dart';
import 'package:mystagepass_mobile/providers/favorite_provider.dart';
import 'package:mystagepass_mobile/providers/notification_provider.dart';
import 'package:mystagepass_mobile/providers/performer_provider.dart';
import 'package:mystagepass_mobile/providers/genre_provider.dart';
import 'package:mystagepass_mobile/providers/purchase_provider.dart';
import 'package:mystagepass_mobile/providers/review_provider.dart';
import 'package:mystagepass_mobile/providers/event_provider.dart';
import 'package:mystagepass_mobile/providers/ticket_provider.dart';
import 'package:mystagepass_mobile/providers/payment_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'utils/colors_helpers.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
      "pk_test_51T6FAZHVJUmB5QSKvJPO6LojCq0SIr2Lpj1AtlY5tTtjboQeXoWzxifNBJDNI2H3PJYMA0b0FqVXBmt5B9uwOujP001QV1Py32";
  await Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PerformerProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
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

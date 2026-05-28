import 'package:flutter/material.dart';
import 'package:mystagepass_admin/providers/admin_provider.dart';
import 'package:mystagepass_admin/providers/country_provider.dart';
import 'package:mystagepass_admin/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'utils/colors.dart';
import 'providers/user_provider.dart';
import 'providers/performer_provider.dart';
import 'providers/event_provider.dart';
import 'providers/city_provider.dart';
import 'providers/location_provider.dart';
import 'providers/report_provider.dart';
import 'providers/cancelled_events_report_provider.dart';
import 'providers/genre_provider.dart';
import 'widgets/sidebar_layout.dart';
import 'screens/user_management_screen.dart';
import 'screens/event_management_screen.dart';
import 'screens/performer_management_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/reference_data_screen.dart';
import 'screens/genres_screen.dart';
import 'screens/status_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SidebarLayout.registerScreen(
    SidebarRoutes.users,
    (id) => UserManagementScreen(userId: id),
  );
  SidebarLayout.registerScreen(
    SidebarRoutes.events,
    (id) => EventManagementScreen(userId: id),
  );
  SidebarLayout.registerScreen(
    SidebarRoutes.performers,
    (id) => PerformerManagementScreen(userId: id),
  );
  SidebarLayout.registerScreen(
    SidebarRoutes.reports,
    (id) => ReportsScreen(userId: id),
  );
  SidebarLayout.registerScreen(
    SidebarRoutes.referenceData,
    (id) => ReferenceDataScreen(userId: id),
  );
  SidebarLayout.registerScreen(
    SidebarRoutes.genres,
    (userId) => GenresScreen(userId: userId),
  );
  SidebarLayout.registerScreen(
    SidebarRoutes.statuses,
    (userId) => StatusScreen(userId: userId),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => PerformerProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => CancelledEventsReportProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
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

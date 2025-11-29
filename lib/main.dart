import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/report_issue.dart';
import 'screens/my_complaints.dart';
import 'screens/notifications.dart';
import 'screens/profile.dart';
import 'screens/complaint_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UrbanFixApp());
}

class UrbanFixApp extends StatelessWidget {
  const UrbanFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'UrbanFix',
        theme: ThemeData(
          primaryColor: const Color(0xFF3F8CFF),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF3F8CFF),
            secondary: const Color(0xFF3F8CFF),
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/report': (_) => const ReportIssueScreen(),
          '/my': (_) => const MyComplaintsScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ComplaintDetailScreen.routeName) {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
                builder: (_) => ComplaintDetailScreen(id: args?['id']));
          }
          return null;
        },
      ),
    );
  }
}

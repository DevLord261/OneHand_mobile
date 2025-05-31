import 'package:flutter/material.dart';
import 'package:OneHand/data/DB.dart';
import 'package:OneHand/models/Campaign.dart';
import 'package:OneHand/screen/campaign_details.dart';
import 'package:OneHand/screen/create_campaign.dart';
import 'package:OneHand/screen/Home.dart';
import 'package:OneHand/screen/my_campaigns.dart';
import 'package:OneHand/widget/main_navigation.dart';
import 'package:OneHand/screen/Login.dart';
import 'package:OneHand/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBContext.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneHand',
      theme: ThemeData(
        primaryColor: Colors.lightBlue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: AuthCheck(),
      routes: {
        '/home': (context) => const Home(),
        '/create_campaign': (context) => const CreateCampaign(),
        '/my_campaigns': (context) => const MyCampaigns(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/campaign_details') {
          final Campaign campaign = settings.arguments as Campaign;
          return MaterialPageRoute(
            builder: (context) => CampaignDetails(campaign: campaign),
          );
        }
        return null;
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          final bool isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const MainNavigation() : const Login();
        }
      },
    );
  }
}

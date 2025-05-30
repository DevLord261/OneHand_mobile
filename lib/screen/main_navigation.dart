import 'package:flutter/material.dart';
import 'package:flutterproject/screen/home.dart';
import 'package:flutterproject/screen/create_campaign.dart';
import 'package:flutterproject/screen/my_campaigns.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List of widgets to display
  static final List<Widget> _widgetOptions = <Widget>[
    const Home(),
    CreateCampaign(),
    const MyCampaigns(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 30),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'My Campaigns',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: _onItemTapped,
      ),
    );
  }
}

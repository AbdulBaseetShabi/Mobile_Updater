import 'package:flutter/material.dart';
import 'package:resume_updater/screens/contact.dart';
import 'package:resume_updater/screens/experience.dart';
import 'package:resume_updater/screens/introduction.dart';
import 'package:resume_updater/screens/profile.dart';
import 'package:resume_updater/screens/projects.dart';

class Navigation extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home)),
    BottomNavigationBarItem(icon: Icon(Icons.person)),
    BottomNavigationBarItem(icon: Icon(Icons.business_center)),
    BottomNavigationBarItem(icon: Icon(Icons.library_books)),
    BottomNavigationBarItem(icon: Icon(Icons.perm_contact_calendar))
  ];

  final List<Widget> _navPages = [
    Introduction(),
    Profile(),
    Experience(),
    Projects(),
    Contact()
  ];
  int _currentNavigation = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: _navPages[_currentNavigation],
        scrollDirection: Axis.vertical,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentNavigation = index;
          });
        },
        backgroundColor: Colors.blueGrey[400],
      ),
    );
  }
}

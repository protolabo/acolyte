import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'userData.dart';
import 'loginPage.dart';
import 'profile.dart';
import 'chat.dart';
import 'offers.dart';
import 'requests.dart';


class HomePage extends StatefulWidget {
  final int boolMode;

  const HomePage({Key? key, required this.boolMode}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;
  
  // Define icon data for each page
  final List<IconData> icons = [
    Icons.chat,
    Icons.request_page,
    Icons.local_offer,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/userdata.json');
      print("please place the json file at this path : ");
      print(file);
      if (!file.existsSync()) {
        throw Exception('User data file not found.');
      }
      final contents = await file.readAsString();
      final Map<String, dynamic> userData = jsonDecode(contents);
      UserData().loadData(userData);
    } catch (e) {
      // If loading fails, show an error and redirect to login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginError();
      });
    }
  }

  void _showLoginError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to load user data. Please log in again.'),
        backgroundColor: Colors.white,
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen(boolMode: widget.boolMode))
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> getPages() {
    // Assuming pages are appropriately defined elsewhere and do not need userData passed directly anymore
    return widget.boolMode == 1
      ? [BlueChat(), BlueRequests(), BlueMyOffers(), BlueProfile()]
      : [RedChat(), RedOffers(), RedMyRequests(), RedProfile()];
  }

  List<String> getLabels() {
    return widget.boolMode == 1
      ? ['Chat', 'Requests', 'My Offers', 'Profile']
      : ['Chat', 'Offers', 'My Requests', 'Profile'];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = getPages();
    List<String> labels = getLabels();
    Color backgroundColor = widget.boolMode == 1 ? myBlue : myRed;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Logged in as ${UserData().data['userId']} ${UserData().data['username']}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: pages[_selectedPageIndex],
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              color: backgroundColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (index) => NavBarIcon(
                      icon: icons[index],
                      label: labels[index],
                      isActive: _selectedPageIndex == index,
                      onTap: () => setState(() => _selectedPageIndex = index),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavBarIcon({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.white : Colors.white60),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

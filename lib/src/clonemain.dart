// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api, avoid_print, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, sort_child_properties_last

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(const MyApp());
}
// Define custom colors as Color objects
// ignore: duplicate_ignore
// ignore: prefer_const_constructors
final Color myRed = Color(0xFFFF6868);
final Color myBlue = Color(0xFF356DFF);

String generateUUID() {
  return const Uuid().v4();
}

class UserData {
  static final UserData _instance = UserData._internal();
  Map<String, dynamic> data = {};

  UserData._internal();

  factory UserData() => _instance;

  void loadData(Map<String, dynamic> newData) {
    data = newData;
  }

  Future<void> saveData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/userdata.json');
    await file.writeAsString(jsonEncode(data));
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Background with Text',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _boolMode = 0; // 0 for red, 1 for blue
  double _orbPosition = 0.5; // Represents the horizontal position of the orb

  void _updateOrbPosition(Offset localPosition, Size screenSize) {
    final localDx = localPosition.dx.clamp(0.0, screenSize.width);
    setState(() {
      _orbPosition = localDx / screenSize.width;
      _boolMode = _orbPosition >= 0.5 ? 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _updateOrbPosition(details.localPosition, screenSize);
        },
        onHorizontalDragEnd: (details) {
          // Check if the orb position crosses 75% or 25% of the screen width
          if (_orbPosition > 0.75 || _orbPosition < 0.25) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => LoginScreen(boolMode: _boolMode),
            ));
          } else {
            // Reset the orb's position to the center as an elastic effect if it doesn't meet the criteria
            setState(() {
              _orbPosition = 0.5;
            });
          }
        },
        child: Stack(
          children: <Widget>[
            CustomPaint(
              size: screenSize,
              painter: CurvePainter(orbPosition: _orbPosition),
            ),
            Positioned(
              left: screenSize.width * _orbPosition - 30,
              top: calculateParabolicY(_orbPosition, screenSize) - 30,
              child: const Orb(),
            ),
            Positioned(
              top: screenSize.height * 0.2,
              left: 0,
              right: 0,
              child: Center(
                child: const Text(
                  'ACOLYTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenSize.height * 0.55,
              left: 0,
              right: screenSize.width / 2,
              child: Center(
                child: FittedBox(
                  child: Text(
                    "Je recherche un service",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenSize.height * 0.55,
              left: screenSize.width / 2,
              right: 0,
              child: Center(
                child: FittedBox(
                  child: Text(
                    "J'offre mes services",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateParabolicY(double position, Size screenSize) {
    double x = position - 0.5;
    double a = 0.5 * screenSize.height;
    double y = a * x * x + screenSize.height / 2;
    return y;
  }
}

class Orb extends StatelessWidget {
  final double diameter = 60;

  const Orb({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double orbPosition;

  CurvePainter({required this.orbPosition});

  @override
  void paint(Canvas canvas, Size size) {

    final redPaint = Paint()..color = myRed; // Custom red color
    final bluePaint = Paint()..color = myBlue; // Custom blue color
    final curvePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;  // Updated the stroke width to make it thicker

    // Draw the background split
    double splitPoint = size.width * (1-orbPosition); // Invert the orb position for the split point
    canvas.drawRect(Rect.fromLTRB(0, 0, splitPoint, size.height), redPaint);
    canvas.drawRect(Rect.fromLTRB(splitPoint, 0, size.width, size.height), bluePaint);

    // Draw the white curve
    Path path = Path();
    for (double i = 0; i <= size.width; i++) {
      double x = i / size.width - 0.5; // Normalize x to [-0.5, 0.5]
      double a = 0.5 * size.height; // Scaling factor for the parabola
      double y = a * x * x + size.height / 2; // Parabolic equation for y
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }
    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LoginScreen extends StatelessWidget {
  final int boolMode;

  const LoginScreen({Key? key, required this.boolMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = boolMode == 1 ? myBlue : myRed;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Acolyte !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            LoginButton(
              text: 'Sign in with Google',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 16),
            LoginButton(
              text: 'Sign in with Facebook',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 16),
            LoginButton(
              text: 'Sign in with Twitter',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 16),
            LoginButton(
              text: 'Sign in with Email',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 16),
            LoginButton(
              text: 'Sign in with Apple',
              onPressed: () {
                _navigateToPlaceholder(context, boolMode);
              },
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () => _navigateToPlaceholder(context, boolMode),
              child: const Text(
                "Don't have an account? Sign up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _navigateToPlaceholder(BuildContext context, int boolMode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HomePage(boolMode: boolMode),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const LoginButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        minimumSize: const Size(280, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(text),
    );
  }
}

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

// Utility method to create the internal white page container
Widget _buildInternalPageContainer(Widget child) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}
Widget _buildAddButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.all(16),
        width: 56, // Standard FAB size
        height: 56, // Standard FAB size
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
String _getImagePath(Map<String, dynamic> request) {
  String serviceType = request['buddyType'];
  
  if (serviceType == 'Driving Buddy') {
    String? vehicleType = request['vehicleType']; // Extract vehicleType if available
    
    if (vehicleType != null) {
      switch (vehicleType) {
        case 'SUV':
          return 'assets/suv.png';
        case 'Pickup':
          return 'assets/pickup.png';
        case 'Sedan':
          return 'assets/sedan.png';
        case 'Sports':
          return 'assets/sport.png';
        case 'Luxury':
          return 'assets/luxury.png';
        default:
          return 'assets/driving.png'; // Fallback image for 'Driving Buddy'
      }
    } else {
      return 'assets/driving.png'; // Default 'Driving Buddy' image if no vehicleType
    }
  } else if (serviceType == 'Scholar Buddy') {
    return 'assets/classes.png';
  } else {
    return 'assets/default.png'; // Default image if none matches
  }
}


// Red Pages
class RedChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildInternalPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Chat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RedOffers extends StatefulWidget {
  @override
  _RedOffersState createState() => _RedOffersState();
}

class _RedOffersState extends State<RedOffers> {
  List<Map<String, dynamic>> offerData = [];

  @override
  void initState() {
    super.initState();
    _loadOfferData();
  }

  Future<void> _loadOfferData() async {
    try {
      final String response = await rootBundle.loadString('data/offers.json');
      final data = jsonDecode(response);
      if (data is Map<String, dynamic> && data.containsKey('services')) {
        final serviceList = data['services'] as List<dynamic>;
        setState(() {
          offerData = serviceList.cast<Map<String, dynamic>>();
        });
      } else {
        print('Invalid JSON data structure');
        _showLoadingError();
      }
    } catch (e) {
      print('Failed to load offer data: $e');
      _showLoadingError();
    }
  }

  void _showLoadingError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to load requests data.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _reloadOffers() {
    setState(() {
      _loadOfferData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildInternalPageContainer(
      LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  'Current Offers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Expanded(
                child: offerData.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: offerData.length,
                        itemBuilder: (context, index) {
                          var offer = offerData[index];
                          String imagePath = _getImagePath(offer);
                          String detail = "${offer['buddyType']} - ${offer['title']}";
                          return GestureDetector(
                            onTap: () {
                              _showOfferCardDialog(context, offer);
                            },
                            child: Container(
                              height: constraints.maxHeight * 0.15,
                              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
                              child: Card(
                                child: Stack(
                                  children: [
                                    ListTile(
                                      title: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          detail,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${offer["instructor"]} - ${offer["location"]}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16,
                                      bottom: 8,
                                      child: Text(
                                        '\$${offer["price"]}',
                                        style: TextStyle(
                                          color: Color(0xFFFF6868),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 16,
                                      bottom: 8,
                                      child: Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        height: constraints.maxHeight * 0.15 * 0.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _reloadOffers,
                tooltip: "Refresh Offers",
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOfferCardDialog(BuildContext context, Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.deepOrange[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: OfferCard(offer: offer),
          ),
        );
      },
    );
  }

  Widget _buildInternalPageContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}

class OfferCard extends StatelessWidget {
  final Map<String, dynamic>? offer;

  OfferCard({this.offer});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Header Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.2 * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        offer?['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'By ${offer?['instructor'] ?? ''}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.75 * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left-aligned Fields
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildField('Type of Service', offer?['typeOfService'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Scholar Buddy')
                            _buildField('Subject Taught', offer?['subjectTaught'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Scholar Buddy')
                            _buildField('Education Level', offer?['educationLevel'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Driving Buddy')
                            _buildField('Auto Type', offer?['autoType'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Driving Buddy')
                            _buildField('Vehicle Make', offer?['vehicleMake'] ?? '-', 'start'),
                          if (offer?['buddyType'] == 'Driving Buddy')
                            _buildField('Vehicle Type', offer?['vehicleType'] ?? '-', 'start'),
                          _buildField('Skill Level', offer?['skillLevel'] ?? '-', 'start'),
                        ],
                      ),

                      // Right-aligned Fields
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildField('Buddy Type', offer?['buddyType'] ?? '-', 'end'),
                          _buildField('Location', offer?['location'] ?? '-', 'end'),
                          _buildField('Availability', offer?['availability'] ?? '-', 'end'),
                          _buildField('Instructor', offer?['instructor'] ?? '-', 'end'),
                          _buildField('Experience', offer?['instructorExperience'] ?? '-', 'end'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Footer Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.1 * 0.7, // 10% of the screen height
                  child: Center(
                    child: CupertinoButton.filled(
                      child: Text('Chat'),
                      onPressed: () {
                        // No action for now
                      },
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, String alignment) {
    // Determine alignment based on the `alignment` argument
    CrossAxisAlignment crossAxisAlignment;
    if (alignment == 'start') {
      crossAxisAlignment = CrossAxisAlignment.start;
    } else if (alignment == 'end') {
      crossAxisAlignment = CrossAxisAlignment.end;
    } else {
      crossAxisAlignment = CrossAxisAlignment.center;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class RedMyRequests extends StatefulWidget {
  @override
  _RedMyRequestsState createState() => _RedMyRequestsState();
}

class _RedMyRequestsState extends State<RedMyRequests> {
  Future<List<Map<String, dynamic>>> readRequests() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/myrequests.json');
      final contents = await file.readAsString();
      final requests = json.decode(contents) as List;
      return requests.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

void _showEditRequestDialog(BuildContext context, Map<String, dynamic> request) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.deepOrange[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(20),
          child: RequestForm(
            isEditing: true,
            request: request,
            onSave: _reloadRequests,
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return _buildInternalPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'My Requests',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: readRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading requests'));
                } else {
                  final requests = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final imagePath = _getImagePath(request);
                      final detail = "${request['buddyType']} - ${request['title']}";
                      return GestureDetector(
                        onTap: () {
                          _showEditRequestDialog(context, request);
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.15,
                          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                          child: Card(
                            child: Stack(
                              children: [
                                ListTile(
                                  title: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      detail,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${request["location"]} - ${request["availability"]}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  bottom: 8,
                                  child: Text(
                                    '${request["budget"]}\$ / hr',
                                    style: TextStyle(
                                      color: Color(0xFFFF6868),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  bottom: 8,
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.height * 0.15 * 0.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          _buildAddButton(context),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _reloadRequests,
            tooltip: "Refresh Requests",
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: () {
          _showAddRequestDialog(context);
        },
        child: Container(
          margin: EdgeInsets.only(right: 16, bottom: 16),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInternalPageContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  void _showAddRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.deepOrange[400],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: RequestForm(
              onSave: _reloadRequests, // Pass the reload function to the form
            ),
          ),
        );
      },
    );
  }

  void _reloadRequests() {
    setState(() {
      // This will trigger the FutureBuilder to rebuild and fetch the requests again
    });
  }
}

class RequestForm extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? request;
  final VoidCallback? onSave;
  RequestForm({this.isEditing = false, this.request, this.onSave});

  @override
  _RequestFormState createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController whenController = TextEditingController();
  TextEditingController autoTypeController = TextEditingController();
  TextEditingController educationLevelController = TextEditingController();
  TextEditingController skillLevelController = TextEditingController();
  TextEditingController subjectDetailsController = TextEditingController();

  String selectedLocation = '';
  String selectedServiceType = '';
  String selectedEducationLevel = '';
  String selectedSkillLevel = '';
  List<String> locations = ['-', 'Online', 'Montreal', 'Quebec', 'Laval', 'Longueuil'];
  List<String> services = ['-', 'Driving Lessons',
    'Math Classes',
    'Biology Classes',
    'Physics Classes',
    'STEM Classes',
    'Languages Classes',
    'Computer Science Classes'];
  List<String> educationLevels = ['-', 'Preschool', 'HighSchool', 'College', 'University'];
  List<String> skillLevels = ['-', 'Beginner', 'Intermediate', 'Advanced', 'Expert'];

  bool isFormModified = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.request != null) {
      // Set the form fields with the request data
      titleController.text = widget.request!['title'];
      selectedLocation = widget.request!['location'];
      budgetController.text = widget.request!['budget'];
      whenController.text = widget.request!['availability'];
      selectedServiceType = widget.request!['serviceType'];
      autoTypeController.text = widget.request!['autoType'];
      selectedEducationLevel = widget.request!['educationLevel'];
      selectedSkillLevel = widget.request!['skillLevel'];
      subjectDetailsController.text = widget.request!['subjectDetails'];
    }

    // Add listeners to text controllers to update form modification status
    titleController.addListener(() => setState(() => isFormModified = true));
    locationController.addListener(() => setState(() => isFormModified = true));
    budgetController.addListener(() => setState(() => isFormModified = true));
    whenController.addListener(() => setState(() => isFormModified = true));
    autoTypeController.addListener(() => setState(() => isFormModified = true));
    educationLevelController.addListener(() => setState(() => isFormModified = true));
    skillLevelController.addListener(() => setState(() => isFormModified = true));
    subjectDetailsController.addListener(() => setState(() => isFormModified = true));
  }
  Future<void> _saveRequest() async {
    String selectedbuddyType = '';

    // Determine buddy type based on the selected service
    if (selectedServiceType == 'Driving Lessons') {
      selectedbuddyType = 'Driving Buddy';
    } else if (services.sublist(1).contains(selectedServiceType)) {
      selectedbuddyType = 'Scholar Buddy';
    }

    // Gather form data
    final formData = {
      'title': titleController.text,
      'location': selectedLocation,
      'budget': budgetController.text,
      'availability': whenController.text,
      'serviceType': selectedServiceType,
      'buddyType': selectedbuddyType,
      'autoType': autoTypeController.text,
      'educationLevel': selectedEducationLevel,
      'skillLevel': selectedSkillLevel,
      'subjectDetails': subjectDetailsController.text,
    };

    // Get the current Unix timestamp in seconds
    final currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    // Read the existing requests
    final requests = await readRequests();

    if (widget.isEditing && widget.request != null) {
      // Update the existing request
      final existingRequest = widget.request;
      requests.removeWhere((request) => request['uuid'] == existingRequest!['uuid']);
      requests.add({
        'uuid': existingRequest!['uuid'],
        'username': UserData().data['username'],
        'student': UserData().data['name'],
        'active': "true",
        ...formData,
        'DateCreation': existingRequest['DateCreation'], // Keep original creation date
        'DateUpdate': currentTimestamp, // Update modification date in Unix format
      });
    } else {
      // Add the new request with new `uuid`, `DateCreation`, and `DateUpdate` fields
      requests.add({
        'uuid': generateUUID(),
        'username': UserData().data['username'],
        'student': UserData().data['name'],
        'active': "true",
        ...formData,
        'DateCreation': currentTimestamp, // Use current date in Unix format
        'DateUpdate': currentTimestamp, // Same as creation for new requests
      });
    }

    // Write the updated requests to the file
    await writeRequests(requests);

    // Trigger the optional `onSave` callback if provided
    if (widget.onSave != null) {
      widget.onSave!();
    }

    // Close the dialog to exit the form
    Navigator.of(context).pop();
  }
  
  Future<List<Map<String, dynamic>>> readRequests() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/myrequests.json');
      final contents = await file.readAsString();
      final requests = json.decode(contents) as List;
      return requests.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<File> writeRequests(List<Map<String, dynamic>> requests) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/myrequests.json');
    final jsonString = json.encode(requests);
    return file.writeAsString(jsonString);
  }

  String generateUUID() {
    return const Uuid().v4();
  }

  void _resetForm() {
    titleController.clear();
    locationController.clear();
    budgetController.clear();
    whenController.clear();
    autoTypeController.clear();
    educationLevelController.clear();
    skillLevelController.clear();
    subjectDetailsController.clear();
    selectedLocation = '-';
    selectedServiceType = '-';
    selectedEducationLevel = '-';
    selectedSkillLevel = '-';
    isFormModified = false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      _buildFormRow('Title', titleController),
                      _buildDropdownRow('Type of Service', services, selectedServiceType, (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedServiceType = newValue;
                            isFormModified = true;
                          }
                        });
                      }),
                      _buildDropdownRow('Location', locations, selectedLocation, (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedLocation = newValue;
                            isFormModified = true;
                          }
                        });
                      }),
                      _buildFormRow('When', whenController),
                      _buildFormRow('Budget', budgetController, TextInputType.number),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                if (selectedServiceType == 'Driving Lessons')
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        _buildFormRow('Subject Details', subjectDetailsController),
                        _buildDropdownRow('Auto Type', ['Automatic', 'Manual'], autoTypeController.text, (String? newValue) {
                          setState(() {
                            autoTypeController.text = newValue ?? 'Automatic';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow('Skill Level', skillLevels, selectedSkillLevel, (String? newValue) {
                          setState(() {
                            selectedSkillLevel = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                      ],
                    ),
                  )
                else if (selectedServiceType == 'Math Classes' ||
                    selectedServiceType == 'Biology Classes' ||
                    selectedServiceType == 'Physics Classes' ||
                    selectedServiceType == 'STEM Classes' ||
                    selectedServiceType == 'Languages Classes' ||
                    selectedServiceType == 'Computer Science Classes')                  
                    Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        _buildFormRow('Subject Details', subjectDetailsController),
                        _buildDropdownRow('Education Level', educationLevels, selectedEducationLevel, (String? newValue) {
                          setState(() {
                            selectedEducationLevel = newValue ?? '-';
                            isFormModified = true;
                          });
                          
                        }),
                        _buildDropdownRow('Skill Level', skillLevels, selectedSkillLevel, (String? newValue) {
                          setState(() {
                            selectedSkillLevel = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                      ],
                    ),
                  ),
                if (isFormModified)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoButton.filled(
                      child: Text('Save'),
                      onPressed: _saveRequest,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: label,
              keyboardType: keyboardType,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0)),
              ),
              style: TextStyle(color: CupertinoColors.black),
              clearButtonMode: OverlayVisibilityMode.editing,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(selectedValue),
                  Icon(CupertinoIcons.down_arrow, size: 16),
                ],
              ),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoActionSheet(
                      actions: items.map((String value) {
                        return CupertinoActionSheetAction(
                          child: Text(value),
                          onPressed: () {
                            Navigator.pop(context);
                            onChanged(value);
                          },
                        );
                      }).toList(),
                      cancelButton: CupertinoActionSheetAction(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RedProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildInternalPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(child: ProfilePage(textColor: const Color.fromARGB(255, 244, 185, 181), boolMode: 0)),
        ],
      ),
    );
  }
}

// Blue Pages
class BlueChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildInternalPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Chat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlueRequests extends StatefulWidget {
  @override
  _BlueRequestsState createState() => _BlueRequestsState();
}

class _BlueRequestsState extends State<BlueRequests> {
  List<Map<String, dynamic>> requestData = [];

  @override
  void initState() {
    super.initState();
    _loadRequestsData();
  }

  Future<void> _loadRequestsData() async {
    try {
      final String response = await rootBundle.loadString('data/requests.json');
      final data = jsonDecode(response);
      if (data is Map<String, dynamic> && data.containsKey('requests')) {
        final requestsList = data['requests'] as List<dynamic>;
        setState(() {
          requestData = requestsList.cast<Map<String, dynamic>>();
        });
      } else {
        print('Invalid JSON data structure');
        _showLoadingError();
      }
    } catch (e) {
      print('Failed to load requests data: $e');
      _showLoadingError();
    }
  }

  void _showLoadingError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to load requests data.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _reloadRequests() {
    setState(() {
      // Re-fetch data or reset state as needed
      _loadRequestsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildInternalPageContainer(
      LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Text(
                  'Current Requests',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Expanded(
                child: requestData.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: requestData.length,
                        itemBuilder: (context, index) {
                          var request = requestData[index];
                          String imagePath = _getImagePath(request);
                          String detail = "${request['buddyType']} - ${request['title']}";
                          return GestureDetector(
                            onTap: () {
                              _showRequestCardDialog(context, request);
                            },
                            child: Container(
                              height: constraints.maxHeight * 0.15,
                              padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05),
                              child: Card(
                                child: Stack(
                                  children: [
                                    ListTile(
                                      title: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          detail,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${request["student"]} - ${request["location"]}\n${request["typeOfService"]}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16,
                                      bottom: 8,
                                      child: Text(
                                        '${request["budget"] ?? 'N/A'}\$ / hr',
                                        style: TextStyle(
                                          color: Color(0xFF356DFF),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 16,
                                      bottom: 8,
                                      child: Image.asset(
                                        imagePath,
                                        fit: BoxFit.cover,
                                        height: constraints.maxHeight * 0.15 * 0.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _reloadRequests,
                tooltip: "Refresh Requests",
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRequestCardDialog(BuildContext context, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.green[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: RequestCard(request: request),
          ),
        );
      },
    );
  }

  Widget _buildInternalPageContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}

class RequestCard extends StatelessWidget {
  final Map<String, dynamic>? request;

  RequestCard({this.request});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Header Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.2 * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        request?['title'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'By ${request?['student'] ?? ''}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.75 * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left-aligned Fields
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildField('Type of Service', request?['typeOfService'] ?? '-','start'),
                          if (request?['buddyType'] == 'Scholar Buddy')
                            _buildField('Subject Details', request?['subjectDetails'] ?? '-','start'),
                          if (request?['buddyType'] == 'Scholar Buddy')
                            _buildField('Education Level', request?['educationLevel'] ?? '-','start'),
                          if (request?['buddyType'] == 'Driving Buddy')
                            _buildField('Auto Type', request?['autoType'] ?? '-','start'),
                          _buildField('Skill Level', request?['skillLevel'] ?? '-','start'),
                        ],
                      ),

                      // Right-aligned Fields
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        
                        children: [
                          _buildField('Buddy Type', request?['buddyType'] ?? '-','end'),
                          _buildField('Location', request?['location'] ?? '-','end'),
                          _buildField('Availability', request?['availability'] ?? '-','end'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Footer Section
                Container(
                  height: MediaQuery.of(context).size.height * 0.1 * 0.7, // 10% of the screen height
                  child: Center(
                    child: CupertinoButton.filled(
                      child: Text('Chat'),
                      onPressed: () {
                        // No action for now
                      },
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, String alignment) {
    // Determine alignment based on the `alignment` argument
    CrossAxisAlignment crossAxisAlignment;
    if (alignment == 'start') {
      crossAxisAlignment = CrossAxisAlignment.start;
    } else if (alignment == 'end') {
      crossAxisAlignment = CrossAxisAlignment.end;
    } else {
      crossAxisAlignment = CrossAxisAlignment.center;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          Divider(),
        ],
      ),
    );
  }

}

class BlueMyOffers extends StatefulWidget {
  @override
  _BlueMyOffersState createState() => _BlueMyOffersState();
}

class _BlueMyOffersState extends State<BlueMyOffers> {
  Future<List<Map<String, dynamic>>> readOffers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/myoffers.json');
      final contents = await file.readAsString();
      final offers = json.decode(contents) as List;
      return offers.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  void _showEditOfferDialog(BuildContext context, Map<String, dynamic> offer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.green[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: OfferForm(
              isEditing: true,
              offer: offer,
              onSave: _reloadOffers, // Pass the reload function to the form
            ),
          ),
        );
      },
    );
  }

@override
Widget build(BuildContext context) {
  return _buildInternalPageContainer(
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'My Offers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: readOffers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading offers'));
              } else {
                final offers = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final imagePath = _getImagePath(offer);
                    final detail = "${offer['buddyType']} - ${offer['title']}";
                    return GestureDetector(
                      onTap: () {
                        _showEditOfferDialog(context, offer);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                        child: Card(
                          child: Stack(
                            children: [
                              ListTile(
                                title: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    detail,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  '${offer["location"]} - ${offer["availability"]}\n${offer["instructor"]}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                bottom: 8,
                                child: Text(
                                  '${offer["price"]}\$ / hr',
                                  style: TextStyle(
                                    color: Color(0xFF356DFF),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 16,
                                bottom: 8,
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  height: MediaQuery.of(context).size.height * 0.15 * 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        _buildAddButton(context),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _reloadOffers,
          tooltip: "Refresh Offers",
        ),
      ],
    ),
  );
}


  Widget _buildAddButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: () {
          _showAddOfferDialog(context);
        },
        child: Container(
          margin: EdgeInsets.only(right: 16, bottom: 16),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInternalPageContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  void _showAddOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.green[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            child: OfferForm(
              onSave: _reloadOffers, // Pass the reload function to the form
            ),
          ),
        );
      },
    );
  }

  void _reloadOffers() {
    setState(() {
      // This will trigger the FutureBuilder to rebuild and fetch the offers again
    });
  }
}

class OfferForm extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? offer;
  final VoidCallback? onSave; // Add an optional callback for saving

  OfferForm({this.isEditing = false, this.offer, this.onSave});

  @override
  _OfferFormState createState() => _OfferFormState();
}

class _OfferFormState extends State<OfferForm> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for common fields
  TextEditingController titleController = TextEditingController(); // title
  TextEditingController locationController = TextEditingController(); // location
  TextEditingController priceController = TextEditingController(); // price
  TextEditingController whenController = TextEditingController(); // availability

  // Text editing controllers for Driving Lessons
  TextEditingController autoTypeController = TextEditingController(); // autoType
  TextEditingController vehicleMakeController = TextEditingController(); // vehicleMake
  TextEditingController vehicleTypeController = TextEditingController(); // vehicleType
  TextEditingController instructorExperienceController = TextEditingController(); // instructorExperience

  // Text editing controllers for Classes
  TextEditingController educationLevelController = TextEditingController(); // educationLevel
  TextEditingController skillLevelController = TextEditingController(); // skillLevel
  TextEditingController subjectTeachedController = TextEditingController(); // Subject Taught

  // Dropdown initial values and lists
  String selectedlocation = '';
  String selectedService = '';
  String selectedVehicleType = '';
  String selectedEducationLevel = '';
  String selectedSkillLevel = '';
  String selectedInstructorExperience = '';
  List<String> locations = ['-', 'Online', 'Montreal', 'Quebec', 'Laval', 'Longueuil'];
  List<String> services = [
    '-',
    'Driving Lessons',
    'Math Classes',
    'Biology Classes',
    'Physics Classes',
    'STEM Classes',
    'Languages Classes',
    'Computer Science Classes'
  ];
  List<String> vehicleTypes = ['-', 'SUV', 'Pickup', 'Sedan', 'Sports', 'Luxury'];
  List<String> educationLevels = ['-', 'Preschool', 'HighSchool', 'College', 'University'];
  List<String> skillLevels = ['-', 'Beginner', 'Intermediate', 'Advanced', 'Expert'];
  List<String> instructorExperiences = ['-', '1 year', '2-5 years', '5-7 years', '8-10 years', '10+ years'];
  bool isFormModified = false;


  // Methods for handling the myoffers.json file
  Future<List<Map<String, dynamic>>> readOffers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/myoffers.json');
      final contents = await file.readAsString();
      final offers = json.decode(contents) as List;
      return offers.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<File> writeOffers(List<Map<String, dynamic>> offers) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/myoffers.json');
    final jsonString = json.encode(offers);
    return file.writeAsString(jsonString);
  }

  String generateUUID() {
    return const Uuid().v4();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.offer != null) {
      // Set the form fields with the offer data
      titleController.text = widget.offer!['title'];
      selectedlocation = widget.offer!['location'];
      priceController.text = widget.offer!['price'];
      whenController.text = widget.offer!['availability'];
      autoTypeController.text = widget.offer!['autoType'];
      vehicleMakeController.text = widget.offer!['vehicleMake'];
      selectedVehicleType = widget.offer!['vehicleType'];
      selectedInstructorExperience = widget.offer!['instructorExperience'];
      selectedEducationLevel = widget.offer!['educationLevel'];
      selectedSkillLevel = widget.offer!['skillLevel'];
      subjectTeachedController.text = widget.offer!['subjectTaught'];
      selectedService = widget.offer!['typeOfService'];
    }

    // Add listeners to text controllers to update form modification status
    titleController.addListener(() => setState(() => isFormModified = true));
    locationController.addListener(() => setState(() => isFormModified = true));
    priceController.addListener(() => setState(() => isFormModified = true));
    whenController.addListener(() => setState(() => isFormModified = true));
    autoTypeController.addListener(() => setState(() => isFormModified = true));
    vehicleMakeController.addListener(() => setState(() => isFormModified = true));
    vehicleTypeController.addListener(() => setState(() => isFormModified = true));
    instructorExperienceController.addListener(() => setState(() => isFormModified = true));
    educationLevelController.addListener(() => setState(() => isFormModified = true));
    skillLevelController.addListener(() => setState(() => isFormModified = true));
    subjectTeachedController.addListener(() => setState(() => isFormModified = true));
  }

  Future<void> _saveOffer() async {
      String selectedbuddyType = '';

      // Determine buddy type based on the selected service
      if (selectedService == 'Driving Lessons') {
        selectedbuddyType = 'Driving Buddy';
      } else if (services.sublist(1).contains(selectedService)) {
        selectedbuddyType = 'Scholar Buddy';
      }

      // Gather form data
      final formData = {
        'title': titleController.text,
        'location': selectedlocation,
        'price': priceController.text,
        'availability': whenController.text,
        'buddyType': selectedbuddyType,
        'typeOfService': selectedService,
        'autoType': autoTypeController.text,
        'vehicleMake': vehicleMakeController.text,
        'vehicleType': selectedVehicleType,
        'instructorExperience': selectedInstructorExperience,
        'educationLevel': selectedEducationLevel,
        'skillLevel': selectedSkillLevel,
        'subjectTaught': subjectTeachedController.text,
      };

      // Get the current Unix timestamp in seconds
      final currentTimestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

      // Read the existing offers
      final offers = await readOffers();

      if (widget.isEditing && widget.offer != null) {
        // Update the existing offer
        final existingOffer = widget.offer;
        offers.removeWhere((offer) => offer['uuid'] == existingOffer!['uuid']);
        offers.add({
          'uuid': existingOffer!['uuid'],
          'username': UserData().data['username'],
          'instructor': UserData().data['name'],
          'active': "true",
          ...formData,
          'DateCreation': existingOffer['DateCreation'], // Keep original creation date
          'DateUpdate': currentTimestamp, // Update modification date in Unix format
        });
      } else {
        // Add the new offer with new `uuid`, `DateCreation`, and `DateUpdate` fields
        offers.add({
          'uuid': generateUUID(),
          'username': UserData().data['username'],
          'instructor': UserData().data['name'],
          'active': "true",
          ...formData,
          'DateCreation': currentTimestamp, // Use current date in Unix format
          'DateUpdate': currentTimestamp, // Same as creation for new offers
        });
      }

      // Write the updated offers to the file
      await writeOffers(offers);

      // Trigger the optional `onSave` callback if provided
      if (widget.onSave != null) {
        widget.onSave!();
      }

      // Close the dialog to exit the form
      Navigator.of(context).pop();
    }
  
  
  void _resetForm() {
    titleController.clear();
    locationController.clear();
    priceController.clear();
    whenController.clear();
    autoTypeController.clear();
    vehicleMakeController.clear();
    vehicleTypeController.clear();
    instructorExperienceController.clear();
    educationLevelController.clear();
    skillLevelController.clear();
    subjectTeachedController.clear();
    selectedlocation = '-';
    selectedService = '-';
    selectedVehicleType = '-';
    selectedEducationLevel = '-';
    selectedSkillLevel = '-';
    selectedInstructorExperience = '-';
    isFormModified = false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      _buildFormRow('Title', titleController),
                      _buildDropdownRow('Type Of Service', services, selectedService, (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedService = newValue;
                            isFormModified = true;
                          }
                        });
                      }),
                      _buildDropdownRow('Location', locations, selectedlocation, (String? newValue) {
                        setState(() {
                          if (newValue != null) {
                            selectedlocation = newValue;
                            isFormModified = true;
                          }
                        });
                      }),
                      _buildFormRow('When', whenController),
                      _buildFormRow('Price', priceController, TextInputType.number),
                    ],
                  ),
                ),
                SizedBox(height: 16.0), // Add some spacing between the containers
                if (selectedService == 'Driving Lessons')
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        _buildFormRow('Vehicle Make', vehicleMakeController),
                        _buildDropdownRow('Auto Type', ['Automatic', 'Manual'], autoTypeController.text, (String? newValue) {
                          setState(() {
                            autoTypeController.text = newValue ?? 'Automatic';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow('Vehicle Type', vehicleTypes, selectedVehicleType, (String? newValue) {
                          setState(() {
                            selectedVehicleType = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow("instructor Experience", instructorExperiences, selectedInstructorExperience, (String? newValue) {
                          setState(() {
                            selectedInstructorExperience = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                      ],
                    ),
                  )
                else if (services.sublist(1).contains(selectedService))
                  Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        _buildFormRow('Subject Taught', subjectTeachedController),
                        _buildDropdownRow('Education Level', educationLevels, selectedEducationLevel, (String? newValue) {
                          setState(() {
                            selectedEducationLevel = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow('Skill Level', skillLevels, selectedSkillLevel, (String? newValue) {
                          setState(() {
                            selectedSkillLevel = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                        _buildDropdownRow("instructor Experience", instructorExperiences, selectedInstructorExperience, (String? newValue) {
                          setState(() {
                            selectedInstructorExperience = newValue ?? '-';
                            isFormModified = true;
                          });
                        }),
                      ],
                    ),
                  ),
                if (isFormModified)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CupertinoButton.filled(
                      child: Text('Save'),
                      onPressed: _saveOffer,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: label,
              keyboardType: keyboardType,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4, width: 0)),
              ),
              style: TextStyle(color: CupertinoColors.black),
              clearButtonMode: OverlayVisibilityMode.editing,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(selectedValue),
                  Icon(CupertinoIcons.down_arrow, size: 16),
                ],
              ),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoActionSheet(
                      actions: items.map((String value) {
                        return CupertinoActionSheetAction(
                          child: Text(value),
                          onPressed: () {
                            Navigator.pop(context);
                            onChanged(value);
                          },
                        );
                      }).toList(),
                      cancelButton: CupertinoActionSheetAction(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }

class BlueProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildInternalPageContainer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(child: ProfilePage(textColor: Color.fromARGB(255, 171, 205, 235), boolMode: 1)),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final Color textColor;
  final int boolMode;

  const ProfilePage({Key? key, required this.textColor, required this.boolMode}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String selectedCountry = 'Canada';
  bool isModified = false;
  final List<String> countries = ["United States", "Canada", "Morocco", "Japan"];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    var userData = UserData().data;
    nameController.text = userData['name'] ?? '';
    lastNameController.text = userData['lastName'] ?? '';
    usernameController.text = userData['username'] ?? '';
    phoneController.text = userData['phone'] ?? '';
    emailController.text = userData['email'] ?? '';
    passwordController.text = userData['password'] ?? '';
    dobController.text = userData['dob'] ?? '';
    selectedCountry = userData['country'] ?? 'Canada';
  }

  void _saveUserData() async {
    if (_validateInputs()) {
      UserData().data = {
        'name': nameController.text,
        'lastName': lastNameController.text,
        'username': usernameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'dob': dobController.text,
        'country': selectedCountry,
      };
      await UserData().saveData();
      setState(() => isModified = false);
    }
  }

  bool _validateInputs() {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text);
    bool phoneValid = RegExp(r"^\+?([0-9]{1,3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{3})[-. ]?([0-9]{4})$").hasMatch(phoneController.text);
    if (!emailValid || !phoneValid || nameController.text.isEmpty || usernameController.text.isEmpty || phoneController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || dobController.text.isEmpty || selectedCountry.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Validation Error'),
          content: Text('Please fill in all fields correctly.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: _buildInternalPageContainer(),
      ),
    );
  }

  Widget _buildInternalPageContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _profileContent(),
    );
  }

  Widget _profileContent() {
    return Column(
      children: [
        _buildTextField(nameController, 'Full Name', false),
        _buildTextField(usernameController, 'Username', false),
        _buildTextField(phoneController, 'Phone Number', false),
        _buildTextField(emailController, 'Email', false),
        _buildTextField(passwordController, 'Password', true),
        _buildDateField(),
        _buildDropdownField(),
        SizedBox(height: 20),
        Visibility(
          visible: isModified,
          child: ElevatedButton(
            onPressed: _saveUserData,
            child: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.textColor,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool obscure) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscure,
      onChanged: (_) => setState(() => isModified = true),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
          setState(() => isModified = true);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: dobController,
          decoration: InputDecoration(labelText: 'Date of Birth'),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedCountry,
      onChanged: (newValue) {
        setState(() {
          selectedCountry = newValue!;
          isModified = true;
        });
      },
      items: countries.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(labelText: 'Country/Region'),
    );
  }
}

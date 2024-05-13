import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';


final Color myRed = Color(0xFFFF6868);
final Color myBlue = Color(0xFF356DFF);
typedef DialogCallback = void Function(BuildContext);

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

class Utils{
// Utility method to create the internal white page container
  static Widget buildInternalPageContainer(Widget child) {
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

  static Widget buildAddButton(BuildContext context, Color color, {required DialogCallback onTap}) {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onTap: () {
          // Invoke the provided function when the button is tapped
          onTap(context);
        },
        child: Container(
          margin: EdgeInsets.only(right: 16, bottom: 16),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  static String getImagePath(Map<String, dynamic> request) {
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

  static String generateUUID() {
    return const Uuid().v4();
  }
}



import 'package:flutter/material.dart';
import 'userData.dart';
import 'loginPage.dart';


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


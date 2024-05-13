import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'userData.dart';

class RedChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Utils.buildInternalPageContainer(
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

class BlueChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Utils.buildInternalPageContainer(
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

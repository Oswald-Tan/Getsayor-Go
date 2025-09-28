import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetTest extends StatefulWidget {
  const InternetTest({super.key});

  @override
  State<InternetTest> createState() => _InternetTestState();
}

class _InternetTestState extends State<InternetTest> {
  bool isConnectedToInternet = false;

  StreamSubscription? _internetConnectionStramSubscription;

  @override
  void initState() {
    super.initState();
    _internetConnectionStramSubscription =
        InternetConnection().onStatusChange.listen((event) {
      print(event);
      switch (event) {
        case InternetStatus.connected:
          setState(() {
            isConnectedToInternet = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnectedToInternet = false;
          });
          break;
        default:
          setState(() {
            isConnectedToInternet = false;
          });
      }
    });
  }

  @override
  void dispose() {
    _internetConnectionStramSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isConnectedToInternet ? Icons.wifi : Icons.wifi_off,
              size: 50,
              color: isConnectedToInternet ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

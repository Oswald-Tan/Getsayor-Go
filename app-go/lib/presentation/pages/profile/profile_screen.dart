import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/profile/components/header_profile.dart';
import 'package:getsayor/presentation/pages/profile/components/menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              SizedBox(
                height: 215,
                child: ProfilePage(),
              ),
              SizedBox(height: 10),
              Menu()
            ],
          ),
        ),
      ),
    );
  }
}

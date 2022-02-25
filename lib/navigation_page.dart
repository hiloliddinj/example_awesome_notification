import 'package:flutter/material.dart';

class NavigationPage extends StatelessWidget {

  static const String route = '/navigationPage';
  const NavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        title: const Text('Navigated Screen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'This is Navigation Page'
        ),
      ),
    );
  }
}

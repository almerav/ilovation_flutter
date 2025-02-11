
import 'package:flutter/material.dart';

class SMCityEventPage extends StatelessWidget {
  const SMCityEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SM City Iloilo Grand Event')),
      body: const Center(
        child: Text(
          'Details about the SM City Iloilo Grand Event.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
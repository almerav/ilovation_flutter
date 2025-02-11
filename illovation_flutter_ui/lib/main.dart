import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:illovation_flutter_ui/eventform.dart';
import 'package:illovation_flutter_ui/eventpage.dart';
import 'package:illovation_flutter_ui/homepage.dart'; // Import HomePage

Future<void> main() async {
  await dotenv.load(fileName: ".env"); // Load environment variables
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const EventForm(),
    const EventPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove Debug Banner
      title: 'ILOVATION',
      home: Scaffold(
        body: _pages[_selectedIndex], // Display selected page
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.purple, // Highlighted tab color
          unselectedItemColor: Colors.grey, // Unselected tab color
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Book Event',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Events',
            ),
          ],
        ),
      ),
      routes: {
        '/eventform': (context) => const EventForm(),
      },
    );
  }
}

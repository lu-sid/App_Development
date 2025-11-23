// lib/main.dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

// Main app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tab & Drawer Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MainScreen(),
    );
  }
}

// Stateful widget to handle bottom navigation
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Screens for bottom navigation
  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    TopicsTabPage(), // Has top tabs
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation Example'),
      ),
      drawer: AppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.topic),
            label: "Topics",
          ),
        ],
      ),
    );
  }
}

// Drawer menu widget
class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Center(
              child: Text(
                "Flutter Drawer",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile Clicked!')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text("Settings"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings Clicked!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Home Page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '🏠 Home Page',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Search Page
// Search Page
class SearchPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Type to search...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              '🔍 Search anything...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// Page containing Top Tabs
class TopicsTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of top tabs
      child: Column(
        children: [
          Material(
            color: Colors.deepPurple,
            child: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Tab A'),
                Tab(text: 'Tab B'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Center(
                    child: Text('📘 Content of Tab A',
                        style: TextStyle(fontSize: 22))),
                Center(
                    child: Text('📗 Content of Tab B',
                        style: TextStyle(fontSize: 22))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

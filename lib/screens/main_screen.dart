import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import './home_screen.dart';
import './categories_screen.dart';
import '../screens/profile_screen.dart';
// import './explore_screen.dart';
// import './wishlist_screen.dart';

class MainScreen extends StatefulWidget
{
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
{
  int _selectedIndex = 0;

  // Create instances of screens 
  final List<Widget> _screens = const [
    HomeScreen(),
    // ExploreScreen(),
    CategoriesScreen(),
    // WishlistScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index)
{
    // Update the state when a tab is tapped
    setState(()
{
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context)
{
    return Scaffold(
      // Use IndexedStack to maintain state of screens
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // This ensures all labels are shown
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.explore_outlined),
        //     activeIcon: Icon(Icons.explore),
        //     label: 'Explore',
        //   ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
        //   BottomNavigationBarItem(
        //     icon: Icon(Icons.favorite_outline),
        //     activeIcon: Icon(Icons.favorite),
        //     label: 'Wishlist',
        //   ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

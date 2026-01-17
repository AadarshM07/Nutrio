import 'package:flutter/material.dart';
import 'package:frontend/pages/dashboard/chat/chat.dart';
import 'dart:ui';
import 'home/home.dart';
import 'search/search.dart';
import 'profile/profile.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool _isChatOpen = false;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isChatOpen = false;
    });
  }

void _openChat() {
    setState(() {
      _isChatOpen = true;
    });
  }

  void _closeChat() {
    setState(() {
      _isChatOpen = false;
    });
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Monday 24 October',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Hi, Alex',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 26),
                  onPressed: () {
                     
                  },
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.green[100],
                  child: const Icon(Icons.person, color: Colors.green, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildBottomNavigation() {
  return ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.only(top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300, 
              width: 1.0,                  
            ),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey[600],
            elevation: 0,
            enableFeedback: false,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _getBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const SearchPage();
      case 2:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    extendBody: true,  
    backgroundColor: Colors.white,
    body: _isChatOpen 
          ? SafeArea(child: ChatPage(onBack: _closeChat)) 
          : Column(
              children: [
                _buildTopBar(),
                Expanded(
                  // Pass the callback to HomePage
                  child: _selectedIndex == 0 
                      ? HomePage(onChatTapped: _openChat) 
                      : _getBodyContent(), 
                ),
              ],
            ),
    bottomNavigationBar: _buildBottomNavigation(),
  );
}

}

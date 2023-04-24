import 'package:flutter/material.dart';
import 'package:hang_out_with_us/card.dart';
import 'package:hang_out_with_us/post.dart';

import 'chatRoomList.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    // SwipeScreen(),
    CardSwipe(),
    ChatList(),
    Text(
      'Slot 2',
    ),
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
        title: const Text("테스트"),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            _widgetOptions.elementAt(_selectedIndex),
            Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Post()))
                        }))
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "chat"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "slot2")
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

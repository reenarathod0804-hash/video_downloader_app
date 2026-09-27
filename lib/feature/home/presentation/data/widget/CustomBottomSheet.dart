import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CustomBottom extends StatefulWidget {
  const CustomBottom({super.key});

  @override
  State<CustomBottom> createState() => _CustomBottomState();
}

class _CustomBottomState extends State<CustomBottom> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      Share.share(
          'Check out my cool app! Download it here: https://yourapp.link');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Home')),
    Center(child: Text('Downloads')),
    Center(child: Text('Share')),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomSheet(onClosing: () {
      Navigator.pop(context);
    }, builder: (context) {
      return Container(
        child: Center(
          child: Text('bottmsheet'),
        ),
      );
    },);
    //   Scaffold(
    //   appBar: AppBar(title: Text('My App')),
    //   body: _widgetOptions[_selectedIndex],
    //   bottomNavigationBar: BottomNavigationBar(
    //     items: const <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    //       BottomNavigationBarItem(
    //           icon: Icon(Icons.download), label: 'Downloads'),
    //       BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Share'),
    //     ],
    //     currentIndex: _selectedIndex,
    //     onTap: _onItemTapped,
    //   ),
    // );
  }
}

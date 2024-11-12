import 'package:flutter/material.dart';
import 'package:kasir/ui/screens/items/item.dart';
import 'package:kasir/ui/screens/suppliers/supplier.dart';

class WidgetNavigationBar extends StatefulWidget {
  const WidgetNavigationBar({Key? key}) : super(key: key);

  @override
  State<WidgetNavigationBar> createState() => _WidgetNavigationBar();
}

class _WidgetNavigationBar extends State<WidgetNavigationBar> {
  int _currentIndex = 0;

  List<Widget> body = [
    const Item(),
    const Supplier(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Kasir'),
      ),
      body: body[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(label: 'Barang', icon: Icon(Icons.shopping_bag)),
          BottomNavigationBarItem(label: 'Supplier', icon: Icon(Icons.local_shipping)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadless/src/screens/home_screen.dart';
import 'package:roadless/src/screens/navigation_screen.dart';

final navigationIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final navigationPageProvider = StateProvider<Widget>((ref) {
  final List<Widget> pages = [
    HomeScreen(),
    NavigationScreen(),
    Center(child: Text('2 Page')),
    Center(child: Text('3 Page')),
  ];

  return pages[ref.watch(navigationIndexProvider)];
});

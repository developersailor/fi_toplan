import 'package:fi_toplan/app/view/gathering_area_list_view.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fi Toplan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GatheringAreaListView(),
    );
  }
}

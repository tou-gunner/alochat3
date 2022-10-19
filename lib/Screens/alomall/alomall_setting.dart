import 'package:alochat/Configs/app_constants.dart';
import 'package:flutter/material.dart';

class SettingTab extends StatefulWidget {
  final List<Widget> items;
  const SettingTab({Key? key, required this.items}) : super(key: key);

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          child: Text('Setting',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2,
            children: widget.items,
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget {
  final TabController tabController;
  const TabBarWidget({Key? key, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TabBar(
        isScrollable: false,
        controller: tabController,
        tabs: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Descripción',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Tab(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on),
                Text('Ubicación'),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

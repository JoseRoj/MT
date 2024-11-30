import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TabBarWidget extends StatelessWidget {
  final TabController tabController;
  const TabBarWidget({Key? key, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TabBar(
        isScrollable: true,
        controller: tabController,
        tabs: const [
          Tab(
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
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on),
                Text('Ubicación'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event),
                Text('Eventos Publicados'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

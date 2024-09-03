import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreenActiveEvents extends StatelessWidget {
  const LoadingScreenActiveEvents({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        containerLoading(),
        containerLoading(),
        containerLoading(),
        containerLoading(),
      ],
    );
  }

  Widget containerLoading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

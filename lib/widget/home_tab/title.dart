import 'package:flutter/material.dart';

class HomeTabTitle extends StatelessWidget {
  final String text;
  const HomeTabTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        overflow: TextOverflow.ellipsis,
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MovieStars extends StatelessWidget {
  const MovieStars({
    super.key,
    required this.stars,
  });

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < stars; i++)
          const Icon(Icons.star, color: Colors.amber)
      ],
    );
  }
}

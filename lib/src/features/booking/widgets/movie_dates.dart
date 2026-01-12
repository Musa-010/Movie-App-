import 'package:flutter/material.dart';

import 'package:flutter_movie_ticket/src/core/data/models/movies.dart';

import 'movie_date_card.dart';

class MovieDates extends StatefulWidget {
  const MovieDates({
    super.key,
    required this.dates,
  });

  final List<MovieDate> dates;

  @override
  State<MovieDates> createState() => _MovieDatesState();
}

class _MovieDatesState extends State<MovieDates> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: widget.dates.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: MovieDateCard(
            date: widget.dates[index],
            isSelected: index == _selectedIndex,
          ),
        );
      },
    );
  }
}

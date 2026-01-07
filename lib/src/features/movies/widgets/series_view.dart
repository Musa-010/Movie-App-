import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_movie_ticket/src/core/data/data.dart';
import 'package:flutter_movie_ticket/src/core/constants/constants.dart';
import 'package:flutter_movie_ticket/src/features/movie/movie_page.dart';

class SeriesView extends StatefulWidget {
  const SeriesView({super.key});

  @override
  State<SeriesView> createState() => _SeriesViewState();
}

class _SeriesViewState extends State<SeriesView>
    with SingleTickerProviderStateMixin {
  late final PageController _seriesCardPageController;
  late final PageController _seriesDetailPageController;

  double _seriesCardPage = 0.0;
  double _seriesDetailsPage = 0.0;
  int _seriesCardIndex = 0;
  final _showSeriesDetails = ValueNotifier(true);

  @override
  void initState() {
    _seriesCardPageController = PageController(viewportFraction: 0.77)
      ..addListener(_seriesCardPagePercentListener);
    _seriesDetailPageController = PageController()
      ..addListener(_seriesDetailsPagePercentListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom + 12;

    return SafeArea(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final w = constraints.maxWidth;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              children: [
                const SizedBox(height: 25),
                //* Series Cards
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _seriesCardPageController,
                    clipBehavior: Clip.none,
                    itemCount: series.length,
                    onPageChanged: (page) {
                      _seriesDetailPageController.animateToPage(
                        page,
                        duration: const Duration(milliseconds: 500),
                        curve: const Interval(
                          0.25,
                          1,
                          curve: Curves.decelerate,
                        ),
                      );
                    },
                    itemBuilder: (_, index) {
                      final seriesItem = series[index];
                      final progress = (_seriesCardPage - index);
                      final scale = ui.lerpDouble(1, .8, progress.abs())!;
                      final isCurrentPage = index == _seriesCardIndex;
                      final isScrolling = _seriesCardPageController
                          .position
                          .isScrollingNotifier
                          .value;
                      final isFirstPage = index == 0;

                      return Transform.scale(
                        alignment: Alignment.lerp(
                          Alignment.topLeft,
                          Alignment.center,
                          -progress,
                        ),
                        scale: isScrolling && isFirstPage
                            ? 1 - progress
                            : scale,
                        child: GestureDetector(
                          onTap: () {
                            _showSeriesDetails.value =
                                !_showSeriesDetails.value;
                            const transitionDuration = Duration(
                              milliseconds: 550,
                            );
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: transitionDuration,
                                reverseTransitionDuration: transitionDuration,
                                pageBuilder: (_, animation, ___) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: MoviePage(movie: seriesItem),
                                  );
                                },
                              ),
                            );
                            Future.delayed(transitionDuration, () {
                              _showSeriesDetails.value =
                                  !_showSeriesDetails.value;
                            });
                          },
                          child: Hero(
                            tag: seriesItem.image,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              transform: Matrix4.identity()
                                ..translate(
                                  isCurrentPage ? 0.0 : -20.0,
                                  isCurrentPage ? 0.0 : 60.0,
                                ),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(70),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 25,
                                    offset: const Offset(0, 25),
                                    color: Colors.black.withOpacity(.2),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage(seriesItem.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                //* Series Details
                Expanded(
                  flex: 1,
                  child: PageView.builder(
                    controller: _seriesDetailPageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: series.length,
                    itemBuilder: (_, index) {
                      final seriesItem = series[index];
                      final opacity = (index - _seriesDetailsPage).clamp(
                        0.0,
                        1.0,
                      );

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: w * .1),
                        child: Opacity(
                          opacity: 1 - opacity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: seriesItem.name,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Text(
                                    seriesItem.name.toUpperCase(),
                                    style: AppTextStyles.movieNameTextStyle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: _showSeriesDetails,
                                builder: (_, value, __) {
                                  return Visibility(
                                    visible: value,
                                    child: Text(
                                      seriesItem.actors.join(', '),
                                      style: AppTextStyles.movieDetails,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
  }

  void _seriesCardPagePercentListener() {
    setState(() {
      _seriesCardPage = _seriesCardPageController.page!;
      _seriesCardIndex = _seriesCardPageController.page!.round();
    });
  }

  void _seriesDetailsPagePercentListener() {
    setState(() {
      _seriesDetailsPage = _seriesDetailPageController.page!;
    });
  }

  @override
  void dispose() {
    _seriesCardPageController
      ..removeListener(_seriesCardPagePercentListener)
      ..dispose();
    _seriesDetailPageController
      ..removeListener(_seriesDetailsPagePercentListener)
      ..dispose();
    super.dispose();
  }
}

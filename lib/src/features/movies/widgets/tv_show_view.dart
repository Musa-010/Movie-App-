import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_movie_ticket/src/core/data/data.dart';
import 'package:flutter_movie_ticket/src/core/constants/constants.dart';
import 'package:flutter_movie_ticket/src/features/movie/movie_page.dart';

class TvShowView extends StatefulWidget {
  const TvShowView({super.key});

  @override
  State<TvShowView> createState() => _TvShowViewState();
}

class _TvShowViewState extends State<TvShowView>
    with SingleTickerProviderStateMixin {
  late final PageController _tvShowCardPageController;
  late final PageController _tvShowDetailPageController;

  double _tvShowCardPage = 0.0;
  double _tvShowDetailsPage = 0.0;
  int _tvShowCardIndex = 0;
  final _showTvShowDetails = ValueNotifier(true);

  @override
  void initState() {
    _tvShowCardPageController = PageController(viewportFraction: 0.77)
      ..addListener(_tvShowCardPagePercentListener);
    _tvShowDetailPageController = PageController()
      ..addListener(_tvShowDetailsPagePercentListener);
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
                //* TV Show Cards
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _tvShowCardPageController,
                    clipBehavior: Clip.none,
                    itemCount: tvShows.length,
                    onPageChanged: (page) {
                      _tvShowDetailPageController.animateToPage(
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
                      final tvShow = tvShows[index];
                      final progress = (_tvShowCardPage - index);
                      final scale = ui.lerpDouble(1, .8, progress.abs())!;
                      final isCurrentPage = index == _tvShowCardIndex;
                      final isScrolling = _tvShowCardPageController
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
                            _showTvShowDetails.value =
                                !_showTvShowDetails.value;
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
                                    child: MoviePage(movie: tvShow),
                                  );
                                },
                              ),
                            );
                            Future.delayed(transitionDuration, () {
                              _showTvShowDetails.value =
                                  !_showTvShowDetails.value;
                            });
                          },
                          child: Hero(
                            tag: tvShow.image,
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
                                  image: AssetImage(tvShow.image),
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
                //* TV Show Details
                Expanded(
                  flex: 1,
                  child: PageView.builder(
                    controller: _tvShowDetailPageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tvShows.length,
                    itemBuilder: (_, index) {
                      final tvShow = tvShows[index];
                      final opacity = (index - _tvShowDetailsPage).clamp(
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
                                tag: tvShow.name,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Text(
                                    tvShow.name.toUpperCase(),
                                    style: AppTextStyles.movieNameTextStyle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: _showTvShowDetails,
                                builder: (_, value, __) {
                                  return Visibility(
                                    visible: value,
                                    child: Text(
                                      tvShow.actors.join(', '),
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

  void _tvShowCardPagePercentListener() {
    setState(() {
      _tvShowCardPage = _tvShowCardPageController.page!;
      _tvShowCardIndex = _tvShowCardPageController.page!.round();
    });
  }

  void _tvShowDetailsPagePercentListener() {
    setState(() {
      _tvShowDetailsPage = _tvShowDetailPageController.page!;
    });
  }

  @override
  void dispose() {
    _tvShowCardPageController
      ..removeListener(_tvShowCardPagePercentListener)
      ..dispose();
    _tvShowDetailPageController
      ..removeListener(_tvShowDetailsPagePercentListener)
      ..dispose();
    super.dispose();
  }
}

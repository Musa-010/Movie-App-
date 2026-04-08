import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/movie_content.dart';

class CastList extends StatelessWidget {
  final List<CastMember> cast;

  const CastList({
    super.key,
    required this.cast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final actor = cast[index];
          return _CastCard(
            actor: actor,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _CastCard extends StatelessWidget {
  final CastMember actor;
  final bool isDark;

  const _CastCard({
    required this.actor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Profile image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              border: Border.all(
                color: isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: actor.profileUrl.isNotEmpty
                  ? Image.network(
                      actor.profileUrl.startsWith('http')
                          ? actor.profileUrl
                          : 'https://image.tmdb.org/t/p/w185${actor.profileUrl}',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            actor.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Character
          Text(
            actor.character,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Iconsax.user,
        size: 32,
        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
      ),
    );
  }
}

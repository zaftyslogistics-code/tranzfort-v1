import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Profile header component with Facebook/Twitter style
/// Includes cover area for ad placement
class ProfileHeader extends StatelessWidget {
  final String? coverImageUrl;
  final String? avatarUrl;
  final String name;
  final bool isVerified;
  final String? bio;
  final String? location;
  final Map<String, String>? stats; // e.g., {'Loads': '120', 'Rating': '4.8★'}
  final VoidCallback? onEditProfile;
  final bool showAdPlaceholder;

  const ProfileHeader({
    super.key,
    this.coverImageUrl,
    this.avatarUrl,
    required this.name,
    this.isVerified = false,
    this.bio,
    this.location,
    this.stats,
    this.onEditProfile,
    this.showAdPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Cover area (180px height) - Ad placement
        Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: coverImageUrl == null
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: coverImageUrl != null
                  ? Image.network(
                      coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: AppColors.primary);
                      },
                    )
                  : showAdPlaceholder
                      ? Center(
                          child: Text(
                            'Ad Placement Area',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : null,
            ),
            // "Sponsored" label if ad
            if (showAdPlaceholder)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Sponsored',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Profile info section
        Transform.translate(
          offset: const Offset(0, -40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar (80px) overlapping cover
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                          width: 4,
                        ),
                        color: AppColors.primary,
                      ),
                      child: avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const Spacer(),
                    if (onEditProfile != null)
                      OutlinedButton(
                        onPressed: onEditProfile,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Name + Verified badge
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 20,
                        color: AppColors.success,
                      ),
                    ],
                  ],
                ),

                // Bio
                if (bio != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    bio!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],

                // Location
                if (location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                // Stats row
                if (stats != null && stats!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: stats!.entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: entry.value,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ${entry.key}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

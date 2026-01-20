import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final Alignment alignment;
  final double opacity;

  const GlowOrb({
    super.key,
    required this.size,
    required this.color,
    this.alignment = Alignment.center,
    this.opacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

// Preset glow orb configurations for different screen types
class GlowOrbPresets {
  static const Map<String, List<Map<String, dynamic>>> screenPresets = {
    'auth': [
      {'size': 280.0, 'color': AppColors.cyanGlowStrong, 'alignment': Alignment.topRight},
      {'size': 320.0, 'color': AppColors.primary, 'alignment': Alignment.bottomLeft},
    ],
    'load': [
      {'size': 240.0, 'color': AppColors.cyanGlowStrong, 'alignment': Alignment.topRight},
      {'size': 280.0, 'color': AppColors.primary, 'alignment': Alignment.bottomLeft},
    ],
    'chat': [
      {'size': 200.0, 'color': AppColors.cyanGlowStrong, 'alignment': Alignment.topRight},
      {'size': 240.0, 'color': AppColors.primary, 'alignment': Alignment.bottomLeft},
    ],
    'profile': [
      {'size': 260.0, 'color': AppColors.cyanGlowStrong, 'alignment': Alignment.topRight},
      {'size': 300.0, 'color': AppColors.primary, 'alignment': Alignment.bottomLeft},
    ],
    'verification': [
      {'size': 220.0, 'color': AppColors.cyanGlowStrong, 'alignment': Alignment.topRight},
      {'size': 260.0, 'color': AppColors.primary, 'alignment': Alignment.bottomLeft},
    ],
  };

  static List<Widget> getGlowOrbsForScreen(String screenType) {
    final presets = screenPresets[screenType] ?? screenPresets['auth']!;
    
    return presets.map((preset) {
      final alignment = preset['alignment'] as Alignment;
      final top = alignment.y == -1.0 ? -140.0 : null;
      final bottom = alignment.y == 1.0 ? -160.0 : null;
      final right = alignment.x == 1.0 ? -120.0 : null;
      final left = alignment.x == -1.0 ? -140.0 : null;
      
      return Positioned(
        top: top,
        bottom: bottom,
        right: right,
        left: left,
        child: GlowOrb(
          size: preset['size'] as double,
          color: preset['color'] as Color,
        ),
      );
    }).toList();
  }
}

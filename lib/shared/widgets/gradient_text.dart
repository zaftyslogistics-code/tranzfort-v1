import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ??
        Theme.of(context).textTheme.headlineMedium ??
        const TextStyle(fontSize: 24);

    final shaderGradient = gradient ??
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.textGradient,
        );

    return ShaderMask(
      shaderCallback: (bounds) => shaderGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: defaultStyle.copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

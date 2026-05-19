import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 48,
    this.borderRadius = 12,
  });

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        AssetPaths.appLogo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            Icons.shield_rounded,
            size: size * 0.55,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

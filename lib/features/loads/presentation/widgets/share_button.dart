import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transfort_app/core/theme/app_colors.dart';

class ShareButton extends StatelessWidget {
  final String loadId;
  final String fromCity;
  final String toCity;
  final String truckType;

  const ShareButton({
    super.key,
    required this.loadId,
    required this.fromCity,
    required this.toCity,
    required this.truckType,
  });

  void _shareLoad(BuildContext context) {
    final shareText =
        'Check out this load: $fromCity to $toCity ($truckType)\nLoad ID: $loadId';

    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Load details copied to clipboard'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _shareLoad(context),
      icon: const Icon(Icons.share, color: AppColors.textSecondary),
      tooltip: 'Share this load',
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import 'sign_art.dart';

/// Shows the ministerial road-sign PNG when present; otherwise chapter SignArt.
class QuestionImage extends StatelessWidget {
  const QuestionImage({
    super.key,
    required this.image,
    required this.chapterId,
    this.chapterLabel = 'Segnale',
    this.height = 200,
  });

  final String? image;
  final int chapterId;
  final String chapterLabel;
  final double height;

  static String? assetPathFor(String? image) {
    final name = image?.trim();
    if (name == null || name.isEmpty) return null;
    final file = name.contains('/') ? name.split('/').last : name;
    if (!file.toLowerCase().endsWith('.png')) return null;
    return 'assets/images/$file';
  }

  @override
  Widget build(BuildContext context) {
    final path = assetPathFor(image);
    if (path == null) {
      return SignArt(chapterId: chapterId, label: chapterLabel, height: height);
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        border: Border.all(color: AppColors.strokeStrong),
        boxShadow: const [
          BoxShadow(color: Color(0x140B1220), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => SignArt(
            chapterId: chapterId,
            label: chapterLabel,
            height: height - 32,
          ),
        ),
      ),
    );
  }
}

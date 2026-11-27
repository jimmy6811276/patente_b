import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_layout.dart';

/// Ministerial road-sign image for a quiz/exam question.
///
/// Loads bytes via [rootBundle] first (more reliable on iOS release than a
/// bare [Image.asset] path lookup), then paints with [Image.memory].
/// Questions without an image show a compact text-only plate — never Flutter's
/// blue "!" broken-image placeholder.
class QuestionImage extends StatefulWidget {
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
  State<QuestionImage> createState() => _QuestionImageState();
}

class _QuestionImageState extends State<QuestionImage> {
  late final Future<_ImageLoad?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant QuestionImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      // Parent rebuilds with a new Future via new State when key changes;
      // quiz screens should key QuestionImage by question id.
    }
  }

  Future<_ImageLoad?> _load() async {
    final path = QuestionImage.assetPathFor(widget.image);
    if (path == null) return null;
    try {
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();
      if (bytes.length < 32) return null;
      // PNG magic number
      if (bytes[0] != 0x89 || bytes[1] != 0x50) return null;
      return _ImageLoad(path: path, bytes: bytes);
    } catch (e, st) {
      debugPrint('QuestionImage failed for ${widget.image}: $e\n$st');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = QuestionImage.assetPathFor(widget.image);
    if (path == null) {
      return _TextOnlyPlate(height: widget.height * 0.42, label: widget.chapterLabel);
    }

    return FutureBuilder<_ImageLoad?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _Frame(
            height: widget.height,
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.emerald),
              ),
            ),
          );
        }

        final data = snap.data;
        if (data == null) {
          return _TextOnlyPlate(height: widget.height * 0.42, label: widget.chapterLabel);
        }

        return _Frame(
          height: widget.height,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.memory(
              data.bytes,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text(
                  widget.chapterLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImageLoad {
  const _ImageLoad({required this.path, required this.bytes});
  final String path;
  final Uint8List bytes;
}

class _Frame extends StatelessWidget {
  const _Frame({required this.height, required this.child});
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}

class _TextOnlyPlate extends StatelessWidget {
  const _TextOnlyPlate({required this.height, required this.label});
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.canvasDeep,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

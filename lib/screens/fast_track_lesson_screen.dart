import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/fast_track_curriculum.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';

/// One-rule-per-slide guided lesson. Advances only after "I learned this".
class FastTrackLessonScreen extends StatefulWidget {
  const FastTrackLessonScreen({
    super.key,
    required this.slides,
    this.startIndex = 0,
  });

  final List<FtSlide> slides;
  final int startIndex;

  @override
  State<FastTrackLessonScreen> createState() => _FastTrackLessonScreenState();
}

class _FastTrackLessonScreenState extends State<FastTrackLessonScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex.clamp(0, widget.slides.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markFtSlideReached(_index);
    });
  }

  FtSlide get _slide => widget.slides[_index];
  bool get _isLast => _index >= widget.slides.length - 1;

  Future<void> _learned() async {
    HapticFeedback.mediumImpact();
    final next = _index + 1;
    await context.read<AppState>().markFtSlideReached(_index);
    if (!mounted) return;
    if (_isLast) {
      await context.read<AppState>().markFtSlideReached(widget.slides.length - 1);
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }
    setState(() => _index = next);
    await context.read<AppState>().markFtSlideReached(next);
  }

  Color get _badgeColor {
    final b = _slide.badge?.toUpperCase() ?? '';
    if (b.contains('FALSO') || b.contains('TRAP')) return AppColors.coral;
    if (b.contains('VERO') || b.contains('SAFE')) return AppColors.emerald;
    if (b.contains('ORDER') || b.contains('SHAPE')) return AppColors.blue;
    return AppColors.ink;
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final slide = _slide;
    final progress = (_index + 1) / widget.slides.length;

    return PremiumScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.section.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        l.ftLessonProgress(_index + 1, widget.slides.length),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.canvasDeep,
                color: AppColors.emerald,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: SingleChildScrollView(
                key: ValueKey(slide.id),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (slide.hint != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.amberDim,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.school_rounded, color: AppColors.amber, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                slide.hint!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  height: 1.35,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (slide.badge != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _badgeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            slide.badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      slide.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (slide.accent != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _badgeColor,
                              Color.lerp(_badgeColor, Colors.black, 0.25)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _badgeColor.withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Text(
                          slide.accent!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      slide.body,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    if (slide.example != null) ...[
                      const SizedBox(height: 16),
                      PremiumCard(
                        borderColor: AppColors.blue.withValues(alpha: 0.25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.ftExample,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.blue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(slide.example!, style: const TextStyle(height: 1.4, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                    if (slide.detail != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        slide.detail!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: NeonButton(
              label: _isLast ? l.ftFinishLesson : l.ftLearnedNext,
              icon: _isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
              onPressed: _learned,
            ),
          ),
        ],
      ),
    );
  }
}

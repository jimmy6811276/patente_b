import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/fast_track_curriculum.dart';
import '../data/fast_track_tricks.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import 'exam_screen.dart';
import 'fast_track_lesson_screen.dart';
import 'fast_track_rules_quiz_screen.dart';

/// Guided Fast Track hub: learn path → rules memory test → exam unlock.
class FastTrackScreen extends StatefulWidget {
  const FastTrackScreen({super.key});

  @override
  State<FastTrackScreen> createState() => _FastTrackScreenState();
}

class _FastTrackScreenState extends State<FastTrackScreen> {
  late final Future<FastTrackTricks> _future = FastTrackTricks.load();

  Future<void> _openLesson(List<FtSlide> slides, {int start = 0}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FastTrackLessonScreen(slides: slides, startIndex: start),
      ),
    );
  }

  Future<void> _openRulesQuiz(FastTrackCurriculum curriculum) async {
    final items = curriculum.buildRulesQuiz(limit: 24);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FastTrackRulesQuizScreen(items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n.of(context);

    return PremiumScaffold(
      child: FutureBuilder<FastTrackTricks>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.emerald));
          }
          final tricks = snap.data!;
          final curriculum = FastTrackCurriculum(tricks, isEn: l.isEn);
          final slides = curriculum.buildSlides();
          final total = slides.length;
          final maxSlide = state.ftMaxSlide.clamp(0, total - 1);
          final learnedAll = state.ftMaxSlide >= total - 1;
          final mastery = state.ftMasteryPassed;
          final resumeAt = learnedAll ? total - 1 : maxSlide;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l.fastTrackScreenTitle,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                l.ftAdminOnly,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(l.ftGuidedSub, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0B1220), Color(0xFF16324F)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l.ftPassBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.ftPassHeadline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.ftGuidedPathIntro,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l.ftFollowPath,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 10),
              _PathStep(
                step: 1,
                title: l.ftStep1Title,
                subtitle: l.ftStep1Sub(maxSlide + 1, total),
                color: AppColors.emerald,
                done: learnedAll,
                active: !learnedAll,
                locked: false,
                cta: learnedAll ? l.ftReviewRules : l.ftStartLearning,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _openLesson(slides, start: resumeAt);
                },
              ),
              _PathStep(
                step: 2,
                title: l.ftStep2Title,
                subtitle: learnedAll
                    ? (mastery
                        ? l.ftStep2Done(state.ftMasteryScore)
                        : l.ftStep2Ready)
                    : l.ftStep2Locked,
                color: AppColors.blue,
                done: mastery,
                active: learnedAll && !mastery,
                locked: !learnedAll,
                cta: mastery ? l.ftRetryRules : l.ftTakeRulesTest,
                onTap: () {
                  if (!learnedAll) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.ftFinishSlidesFirst)),
                    );
                    return;
                  }
                  HapticFeedback.selectionClick();
                  _openRulesQuiz(curriculum);
                },
              ),
              _PathStep(
                step: 3,
                title: l.ftStep3Title,
                subtitle: mastery ? l.ftStep3Ready : l.ftStep3Locked,
                color: AppColors.coral,
                done: false,
                active: mastery,
                locked: !mastery,
                last: true,
                cta: l.ftOpenExam,
                onTap: () {
                  if (!mastery) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.ftPassRulesFirst)),
                    );
                    return;
                  }
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExamScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              PremiumCard(
                borderColor: AppColors.amber.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.ftHowItWorks, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(l.ftHowItWorksBody, style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PathStep extends StatelessWidget {
  const _PathStep({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.cta,
    this.done = false,
    this.active = false,
    this.locked = false,
    this.last = false,
  });

  final int step;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String cta;
  final bool done;
  final bool active;
  final bool locked;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done || active ? color : AppColors.canvasDeep,
                      shape: BoxShape.circle,
                      boxShadow: active
                          ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: done
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : locked
                            ? const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 16)
                            : Text(
                                '$step',
                                style: TextStyle(
                                  color: active ? Colors.white : AppColors.textMuted,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 3,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: (done ? color : AppColors.strokeStrong).withValues(alpha: 0.45),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: last ? 0 : 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(22),
                    child: Ink(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: active ? color.withValues(alpha: 0.45) : AppColors.stroke,
                          width: active ? 1.6 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Color(0x100B1220), blurRadius: 14, offset: Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: (active || done ? color : AppColors.ink).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cta,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: active || done ? color : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

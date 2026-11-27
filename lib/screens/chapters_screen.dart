import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/chapter_media.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../widgets/design_system.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/sign_placeholder.dart';
import 'quiz_screen.dart';

class ChaptersScreen extends StatefulWidget {
  const ChaptersScreen({super.key});

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  String _query = '';

  static const _palette = [
    AppColors.neon,
    AppColors.electric,
    AppColors.orange,
    AppColors.pink,
    AppColors.gold,
    AppColors.redSoft,
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n(state.lang);
    final chapters = state.chapters
        .where(
          (c) =>
              _query.isEmpty ||
              c.nameIt.toLowerCase().contains(_query.toLowerCase()) ||
              c.nameEn.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return PremiumScaffold(
      safeBottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 20, 0),
            child: DsScreenHeader(
              title: l.chaptersTitle,
              subtitle: l.chaptersSubtitle(state.chapters.length, state.totalQuestions),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: l.searchChapter,
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.electric),
                ),
              ),
            ),
          ),
          Expanded(
            child: chapters.isEmpty
                ? Center(
                    child: Text(
                      l.noChaptersFound,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final ch = chapters[i];
                              final color = _palette[ch.id % _palette.length];
                              return _ChapterMediaCard(
                                chapter: ch,
                                color: color,
                                l: l,
                                imageAsset: ChapterMedia.assetPathFor(ch.id),
                              );
                            },
                            childCount: chapters.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            16,
                            20,
                            AppLayout.bottomClearance(context),
                          ),
                          child: Center(
                            child: Text(
                              l.totalChapters(state.chapters.length),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChapterMediaCard extends StatelessWidget {
  const _ChapterMediaCard({
    required this.chapter,
    required this.color,
    required this.l,
    this.imageAsset,
  });

  final Chapter chapter;
  final Color color;
  final L10n l;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppLayout.cardRadius);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              chapterId: chapter.id,
              title: l.chapterName(chapter),
            ),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: radius,
            border: Border.all(color: AppColors.stroke),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 55,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color.withValues(alpha: 0.18),
                              AppColors.canvasDeep,
                            ],
                          ),
                        ),
                      ),
                      if (imageAsset != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                          child: Image.asset(
                            imageAsset!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: ChapterBadge(id: chapter.id, color: color, size: 48),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: ChapterBadge(id: chapter.id, color: color, size: 48),
                        ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chapter.id}'.padLeft(2, '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${(chapter.progress * 100).round()}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.chapterName(chapter),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            height: 1.2,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${l.questionsCount(chapter.totalQuestions)} · ${l.difficulty(chapter.difficulty)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: color.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: chapter.progress,
                            minHeight: 5,
                            backgroundColor: AppColors.canvasDeep,
                            color: chapter.progress > 0.7 ? AppColors.neon : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

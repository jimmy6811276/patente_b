import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
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
            padding: const EdgeInsets.fromLTRB(8, 8, 22, 0),
            child: Row(
              children: [
                if (Navigator.of(context).canPop())
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  )
                else
                  const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.chaptersTitle,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.chaptersSubtitle(state.chapters.length, state.totalQuestions),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                ),
              ],
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
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    physics: const BouncingScrollPhysics(),
                    itemCount: chapters.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      if (i == chapters.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 8),
                          child: Center(
                            child: Text(
                              l.totalChapters(state.chapters.length),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }
                      final ch = chapters[i];
                      final color = _palette[ch.id % _palette.length];
                      return _ChapterTile(chapter: ch, color: color, l: l);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.chapter,
    required this.color,
    required this.l,
  });
  final Chapter chapter;
  final Color color;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            chapterId: chapter.id,
            title: l.chapterName(chapter),
          ),
        ),
      ),
      child: Row(
        children: [
          ChapterBadge(id: chapter.id, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.chapterName(chapter),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  '${l.questionsCount(chapter.totalQuestions)} · ${l.difficulty(chapter.difficulty)}'
                  '${chapter.hasData ? ' · ${(chapter.accuracy * 100).round()}%' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            child: Column(
              children: [
                Text(
                  '${(chapter.progress * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: chapter.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.navyElevated,
                    color: chapter.progress > 0.7 ? AppColors.neon : color,
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

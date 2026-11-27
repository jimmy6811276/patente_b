import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import 'quiz_screen.dart';

class MistakesScreen extends StatelessWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final mistakes = state.mistakes;

    return PremiumScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const Expanded(
                  child: Text(
                    'I miei errori',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: PremiumCard(
              glow: AppColors.orangeGlow,
              borderColor: AppColors.orange.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${mistakes.length} errori salvati',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Raggruppati per capitolo · spaced repetition',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: NeonButton(
                      label: 'Riprova',
                      height: 44,
                      gradient: AppColors.orangeGradient,
                      glow: AppColors.orangeGlow,
                      onPressed: mistakes.isEmpty
                          ? () {}
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const QuizScreen(
                                    title: 'Ripasso errori',
                                    mistakeMode: true,
                                  ),
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: mistakes.isEmpty
                ? const _EmptyMistakes()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: mistakes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = mistakes[i];
                      final q = item.question;
                      return PremiumCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              title: q.chapterNameIt,
                              questions: [q],
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.orange.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    'Cap. ${q.chapterId}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.orange,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.replay_rounded, size: 15, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.wrongCount}× errata',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              q.textIt,
                              style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              q.textEn,
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Corretta: ${q.correctIsTrue ? 'VERO' : 'FALSO'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.neonSoft,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMistakes extends StatelessWidget {
  const _EmptyMistakes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.neon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.neon.withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.verified_rounded, color: AppColors.neon, size: 38),
            ),
            const SizedBox(height: 18),
            const Text(
              'Nessun errore salvato',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Le risposte sbagliate verranno raccolte qui automaticamente e ripassate con la spaced repetition.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

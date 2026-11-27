import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';

/// Flashcard-style road vocabulary — competitor apps always surface this on home.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int _index = 0;
  bool _showEn = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n.of(context);
    final items = state.vocabulary;

    if (items.isEmpty) {
      return PremiumScaffold(
        child: Column(
          children: [
            _Header(title: l.vocabTitle),
            Expanded(
              child: Center(
                child: Text(l.vocabEmpty, style: const TextStyle(color: AppColors.textMuted)),
              ),
            ),
          ],
        ),
      );
    }

    final i = _index.clamp(0, items.length - 1);
    final item = items[i];

    return PremiumScaffold(
      child: Column(
        children: [
          _Header(title: l.vocabTitle, subtitle: '${i + 1}/${items.length}'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  Text(
                    l.vocabSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _showEn = !_showEn);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.blue.withValues(alpha: 0.22)),
                          boxShadow: const [
                            BoxShadow(color: Color(0x140B1220), blurRadius: 22, offset: Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.blueDim,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l.chapterBadge(item.chapterId),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              _showEn ? item.termEn : item.termIt,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _showEn ? item.termIt : item.termEn,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textMuted.withValues(alpha: _showEn ? 0.9 : 0.55),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              l.vocabTapHint,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: i == 0
                              ? null
                              : () => setState(() {
                                    _index = i - 1;
                                    _showEn = false;
                                  }),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(l.previous),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeonButton(
                          label: i >= items.length - 1 ? l.doneLabel : l.next,
                          height: 50,
                          onPressed: () {
                            if (i >= items.length - 1) {
                              Navigator.pop(context);
                              return;
                            }
                            setState(() {
                              _index = i + 1;
                              _showEn = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _ShuffleBar(items: items, onPick: (idx) {
                    setState(() {
                      _index = idx;
                      _showEn = false;
                    });
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShuffleBar extends StatelessWidget {
  const _ShuffleBar({required this.items, required this.onPick});
  final List<VocabularyItem> items;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return TextButton.icon(
      onPressed: () {
        HapticFeedback.selectionClick();
        onPick((DateTime.now().millisecondsSinceEpoch) % items.length);
      },
      icon: const Icon(Icons.shuffle_rounded, size: 18),
      label: Text(l.vocabShuffle),
    );
  }
}

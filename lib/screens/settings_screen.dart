import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/app_lang.dart';
import '../l10n/strings.dart';
import '../models/translation_mode.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../widgets/design_system.dart';
import '../widgets/premium_scaffold.dart';
import 'quiz_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.onBackToHome});

  /// When Settings is the Profile tab, back switches to Home.
  final VoidCallback? onBackToHome;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _confirmReset() async {
    final l = L10n.read(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(l.resetDialogTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
          l.resetDialogBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel, style: const TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.reset),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AppState>().resetProgress();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.read(context).progressReset)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n(state.lang);

    return PremiumScaffold(
      safeBottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, AppLayout.bottomClearance(context)),
        children: [
          DsScreenHeader(
            title: l.settingsTitle,
            showBack: true,
            onBack: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
                return;
              }
              widget.onBackToHome?.call();
            },
          ),
          const SizedBox(height: 20),
          _LanguageCard(
            lang: state.lang,
            l: l,
            onChanged: (v) {
              context.read<AppState>().setLanguage(v);
            },
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.translationEnglish,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  l.translationSubtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final mode in TranslationMode.values) ...[
                      if (mode != TranslationMode.values.first) const SizedBox(width: 8),
                      Expanded(
                        child: _ModeChip(
                          label: switch (mode) {
                            TranslationMode.off => l.translationOff,
                            TranslationMode.sentence => l.translationSentence,
                            TranslationMode.word => l.translationWord,
                          },
                          selected: state.translationMode == mode,
                          onTap: () => context.read<AppState>().setTranslationMode(mode),
                        ),
                      ),
                    ],
                  ],
                ),
                const Divider(color: AppColors.stroke, height: 28),
                _Toggle(
                  title: l.readableFont,
                  subtitle: l.readableFontSub,
                  value: state.readableFont,
                  onChanged: (v) => context.read<AppState>().setReadableFont(v),
                ),
                const Divider(color: AppColors.stroke, height: 28),
                _Toggle(
                  title: l.haptics,
                  subtitle: l.hapticsSubtitle,
                  value: state.hapticsEnabled,
                  onChanged: (v) => context.read<AppState>().setHapticsEnabled(v),
                ),
                const Divider(color: AppColors.stroke, height: 28),
                _Toggle(
                  title: l.offlineMode,
                  subtitle: l.offlineSubtitle,
                  value: true,
                  onChanged: null,
                ),
                const Divider(color: AppColors.stroke, height: 28),
                _Toggle(
                  title: l.audio,
                  subtitle: l.audioSubtitle,
                  value: false,
                  onChanged: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            borderColor: AppColors.neon.withValues(alpha: 0.28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: AppColors.neonGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storage_rounded, color: Colors.white, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.localDatabase,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: AppColors.neon, size: 20),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoRow(label: l.lblChapters, value: '${state.chapters.length}'),
                _InfoRow(label: l.lblQuestions, value: '${state.totalQuestions}'),
                _InfoRow(label: l.lblVocab, value: '${state.vocabulary.length}'),
                _InfoRow(
                  label: l.lblAnswers,
                  value: '${state.stats.totalAnswers}',
                ),
                const SizedBox(height: 8),
                Text(
                  l.allIncluded,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  title: l.bookmarks,
                  bookmarkMode: true,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_rounded, color: AppColors.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.bookmarks, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                        l.bookmarksSubtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            borderColor: AppColors.neon.withValues(alpha: 0.28),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.neon.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neon.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    state.fastTrackUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: AppColors.neonSoft,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.fastTrackSectionRow,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        state.fastTrackUnlocked
                            ? l.fastTrackUnlockedLocal
                            : l.fastTrackLockedCreds,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (state.fastTrackUnlocked)
                  TextButton(
                    onPressed: () async {
                      await context.read<AppState>().lockFastTrack();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(L10n.read(context).fastTrackLockedToast),
                        ),
                      );
                    },
                    child: Text(
                      l.lock,
                      style: const TextStyle(
                        color: AppColors.neonSoft,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            onTap: _confirmReset,
            borderColor: AppColors.red.withValues(alpha: 0.25),
            child: Row(
              children: [
                const Icon(Icons.restart_alt_rounded, color: AppColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.resetProgress, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                        l.resetSubtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patente B',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  l.buildInfo('10113198194'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                    fontSize: 13,
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

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.lang,
    required this.l,
    required this.onChanged,
  });

  final AppLang lang;
  final L10n l;
  final ValueChanged<AppLang> onChanged;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      borderColor: AppColors.electric.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppColors.electricGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.translate_rounded, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.languageTitle,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    Text(
                      l.languageSubtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LangChoice(
                  label: l.italian,
                  selected: lang == AppLang.it,
                  onTap: () => onChanged(AppLang.it),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LangChoice(
                  label: l.englishLang,
                  selected: lang == AppLang.en,
                  onTap: () => onChanged(AppLang.en),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LangChoice extends StatelessWidget {
  const _LangChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.electricGradient : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.stroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: selected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.emerald.withValues(alpha: 0.14) : AppColors.canvasDeep,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.emerald : AppColors.stroke,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: selected ? AppColors.emerald : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.electric,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

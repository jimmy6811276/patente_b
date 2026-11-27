import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import 'quiz_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _en = true;
  bool _haptics = true;
  bool _offline = true;
  bool _audio = false;

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Azzerare i progressi?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'Verranno cancellati risposte, errori, segnalibri ed esiti degli esami. Le domande restano disponibili.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Azzera'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AppState>().resetProgress();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progressi azzerati nel database locale')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return PremiumScaffold(
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          const Text(
            'Impostazioni',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 20),
          PremiumCard(
            child: Column(
              children: [
                _Toggle(
                  title: 'Traduzione inglese',
                  subtitle: 'Mostra EN sotto le domande IT',
                  value: _en,
                  onChanged: (v) => setState(() => _en = v),
                ),
                const Divider(color: AppColors.stroke, height: 28),
                _Toggle(
                  title: 'Feedback aptico',
                  subtitle: 'Vibrazione su risposte',
                  value: _haptics,
                  onChanged: (v) => setState(() => _haptics = v),
                ),
                const Divider(color: AppColors.stroke, height: 28),
                _Toggle(
                  title: 'Modalità offline',
                  subtitle: 'Contenuti sempre disponibili senza rete',
                  value: _offline,
                  onChanged: (v) => setState(() => _offline = v),
                ),
                const Divider(color: AppColors.stroke, height: 28),
                _Toggle(
                  title: 'Audio pronuncia',
                  subtitle: 'Lettura parole italiane chiave',
                  value: _audio,
                  onChanged: (v) => setState(() => _audio = v),
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
                    const Expanded(
                      child: Text(
                        'Database locale',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: AppColors.neon, size: 20),
                  ],
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Capitoli', value: '${state.chapters.length}'),
                _InfoRow(label: 'Domande', value: '${state.totalQuestions}'),
                _InfoRow(label: 'Vocaboli', value: '${state.vocabulary.length}'),
                _InfoRow(
                  label: 'Risposte registrate',
                  value: '${state.stats.totalAnswers}',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tutti i contenuti sono inclusi nell\'app. Nessuna API, nessun download di immagini, nessuna connessione richiesta.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const QuizScreen(
                  title: 'Segnalibri',
                  bookmarkMode: true,
                ),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.bookmark_rounded, color: AppColors.gold),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Segnalibri', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                        'Domande salvate durante i quiz',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
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
                      const Text(
                        'Fast Track',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        state.fastTrackUnlocked
                            ? 'Sbloccato su questo dispositivo'
                            : 'Protetto da credenziali',
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
                        const SnackBar(
                          content: Text('Fast Track bloccato di nuovo'),
                        ),
                      );
                    },
                    child: const Text(
                      'Blocca',
                      style: TextStyle(
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Azzera progressi', style: TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                        'Cancella risposte, errori ed esami',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patente B',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                SizedBox(height: 6),
                Text(
                  'Intelligent bilingual driving-theory platform\nBuild 10113198194 · Flutter iOS + Android',
                  style: TextStyle(
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
  final ValueChanged<bool> onChanged;

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

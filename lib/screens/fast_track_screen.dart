import 'package:flutter/material.dart';

import '../data/fast_track_tricks.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import 'quiz_screen.dart';

/// Private Fast Track — same rules/tricks engine as website `/10113198194`.
class FastTrackScreen extends StatefulWidget {
  const FastTrackScreen({super.key});

  @override
  State<FastTrackScreen> createState() => _FastTrackScreenState();
}

class _FastTrackScreenState extends State<FastTrackScreen> {
  late final Future<FastTrackTricks> _future = FastTrackTricks.load();
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PremiumScaffold(
      child: FutureBuilder<FastTrackTricks>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.emerald));
          }
          final tricks = snap.data!;
          return Column(
            children: [
              Padding(
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
                          Text(
                            l.fastTrackScreenTitle,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            l.isEn
                                ? 'Same rules as private web · /10113198194'
                                : 'Stesse regole del sito privato · /10113198194',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Tab(label: l.isEn ? 'Method' : 'Metodo', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                      _Tab(label: l.isEn ? 'Triggers' : 'Trigger', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                      _Tab(label: l.isEn ? 'Absolutes' : 'Assoluti', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
                      _Tab(label: l.isEn ? 'Signs' : 'Segnali', selected: _tab == 3, onTap: () => setState(() => _tab = 3)),
                      _Tab(label: l.isEn ? 'Plan' : 'Piano', selected: _tab == 4, onTap: () => setState(() => _tab = 4)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: switch (_tab) {
                  0 => _MethodTab(tricks: tricks, l: l),
                  1 => _TriggersTab(tricks: tricks, l: l),
                  2 => _VetoTab(tricks: tricks, l: l),
                  3 => _SignsTab(tricks: tricks, l: l),
                  _ => _PlanTab(tricks: tricks, l: l),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.neonGradient : null,
            color: selected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? Colors.transparent : AppColors.stroke),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({required this.tricks, required this.l});
  final FastTrackTricks tricks;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    final meta = tricks.meta;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        PremiumCard(
          borderColor: AppColors.emerald.withValues(alpha: 0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.isEn ? 'You do not read Italian. You read the shape.' : 'Non leggi l\'italiano. Leggi la forma.',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, height: 1.15, letterSpacing: -0.4),
              ),
              const SizedBox(height: 8),
              Text(
                l.isEn
                    ? 'Every exam question is one fixed sentence from a closed bank. Spot one sign, one word, tap VERO or FALSO.'
                    : 'Ogni domanda è una frase fissa della banca. Individua un segnale, una parola, tocca VERO o FALSO.',
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatPill('${meta['drawTotal']}', l.isEn ? 'questions' : 'domande'),
                  const SizedBox(width: 8),
                  _StatPill('20:00', l.isEn ? 'minutes' : 'minuti'),
                  const SizedBox(width: 8),
                  _StatPill('${meta['maxErrors']}', l.isEn ? 'errors max' : 'errori max'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l.isEn ? 'Five-second order' : 'Ordine in 5 secondi',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...tricks.order.map((o) {
          final m = o as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PremiumCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.blueDim,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${m['n']}',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.blue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${m['t']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${m['d']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          l.isEn ? 'Score layers' : 'Livelli di punteggio',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...tricks.scoreMath.map((row) {
          final m = row as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PremiumCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${m['title']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('${m['desc']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(
                    (m['score'] as num).toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.emerald),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TriggersTab extends StatelessWidget {
  const _TriggersTab({required this.tricks, required this.l});
  final FastTrackTricks tricks;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      itemCount: tricks.deck.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Text(
            l.isEn
                ? 'The 25 triggers — most reliable layer in the bank'
                : 'I 25 trigger — lo strato più affidabile della banca',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          );
        }
        final d = tricks.deck[i - 1] as Map<String, dynamic>;
        final vero = d['label'] == 'VERO';
        return PremiumCard(
          borderColor: (vero ? AppColors.emerald : AppColors.coral).withValues(alpha: 0.28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '«${d['phrase']}»',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: vero ? AppColors.emeraldDim : AppColors.coralDim,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${d['label']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: vero ? AppColors.emerald : AppColors.coral,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${d['en']}', style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text('${d['why']}', style: const TextStyle(fontSize: 13, height: 1.35)),
              if ((d['test'] as String?)?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  '${d['test']}',
                  style: const TextStyle(fontSize: 12, color: AppColors.blue, fontWeight: FontWeight.w700),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l.isEn
                    ? 'Purity ${((d['purity'] as num) * 100).round()}% · ${d['n']} hits'
                    : 'Purezza ${((d['purity'] as num) * 100).round()}% · ${d['n']} casi',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VetoTab extends StatelessWidget {
  const _VetoTab({required this.tricks, required this.l});
  final FastTrackTricks tricks;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    final total = tricks.raw['vetoTotal'] as Map<String, dynamic>? ?? {};
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        PremiumCard(
          borderColor: AppColors.coral.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.isEn ? 'Absolute words lean FALSO' : 'Le parole assolute tendono a FALSO',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                l.isEn
                    ? 'solo / sempre / tutti / mai / esclusivamente… lean FALSO at ~${total['falsoPct'] ?? 71}%. A lean, not a verdict. Trigger beats absolute word.'
                    : 'solo / sempre / tutti / mai / esclusivamente… tendono a FALSO (~${total['falsoPct'] ?? 71}%). Una tendenza, non un verdetto. Il trigger batte la parola assoluta.',
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...tricks.veto.map((v) {
          final m = v as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PremiumCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('«${m['word']}»', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Text('${m['en']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(m['falsoPct'] as num).toStringAsFixed(0)}% F',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.coral),
                      ),
                      Text('${m['tier']}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          l.isEn ? 'Green lean (VERO words)' : 'Parole verdi (tendono a VERO)',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...tricks.green.map((g) {
          final m = g as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PremiumCard(
              padding: const EdgeInsets.all(14),
              borderColor: AppColors.emerald.withValues(alpha: 0.22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('«${m['word']}»', style: const TextStyle(fontWeight: FontWeight.w900)),
                        Text('${m['en']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(
                    '${(m['veroPct'] as num).toStringAsFixed(0)}% V',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.emerald),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SignsTab extends StatelessWidget {
  const _SignsTab({required this.tricks, required this.l});
  final FastTrackTricks tricks;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text(
          l.isEn ? 'Five families' : 'Cinque famiglie',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tricks.families.map((f) {
            final m = f as Map<String, dynamic>;
            return Container(
              width: (MediaQuery.sizeOf(context).width - 48) / 2,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.stroke),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${m['fam']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  Text('${m['famEn']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('${m['shape']}', style: const TextStyle(fontSize: 11, height: 1.3)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          l.isEn ? 'Top sign cards' : 'Carte segnale top',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...tricks.signCards.map((s) {
          final m = s as Map<String, dynamic>;
          final logic = m['logic'] as Map<String, dynamic>? ?? {};
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${m['topicIt']}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        '${m['majority']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: m['majority'] == 'VERO' ? AppColors.emerald : AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if ((logic['test'] as String?)?.isNotEmpty == true)
                    Text('${logic['test']}', style: const TextStyle(fontSize: 12, height: 1.35, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...(m['veroWords'] as List? ?? []).map(
                        (w) => _Chip(text: '$w', color: AppColors.emerald),
                      ),
                      ...(m['falsoWords'] as List? ?? []).map(
                        (w) => _Chip(text: '$w', color: AppColors.coral),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PlanTab extends StatelessWidget {
  const _PlanTab({required this.tricks, required this.l});
  final FastTrackTricks tricks;
  final L10n l;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text(
          l.isEn ? 'Two days, four blocks' : 'Due giorni, quattro blocchi',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          l.isEn
              ? 'Do them in order. Do not jump to the exam — the plan only works if the blocks stay in this sequence.'
              : 'Segui l\'ordine. Non saltare all\'esame: il piano funziona solo se i blocchi restano in sequenza.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 14),
        ...tricks.plan.map((p) {
          final m = p as Map<String, dynamic>;
          final items = (m['items'] as List).cast<String>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PremiumCard(
              borderColor: AppColors.blue.withValues(alpha: 0.22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${m['day']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 8),
                  ...items.map(
                    (it) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle, size: 6, color: AppColors.emerald),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(it, style: const TextStyle(height: 1.35))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        NeonButton(
          label: l.isEn ? 'Practice with quiz' : 'Esercitati con un quiz',
          icon: Icons.play_arrow_rounded,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizScreen(title: l.fastTrackQuiz, hardMode: true),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            l.isEn
                ? 'Progress stays on this device · unlocked Fast Track'
                : 'Progressi sul dispositivo · Fast Track sbloccato',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.big, this.small);
  final String big;
  final String small;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.emeraldDim,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(big, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(small, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

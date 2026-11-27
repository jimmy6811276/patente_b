import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../data/fast_track_curriculum.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';

/// Tests memory of Fast Track rules — not ministerial exam questions.
class FastTrackRulesQuizScreen extends StatefulWidget {
  const FastTrackRulesQuizScreen({super.key, required this.items});

  final List<FtQuizItem> items;

  @override
  State<FastTrackRulesQuizScreen> createState() => _FastTrackRulesQuizScreenState();
}

class _FastTrackRulesQuizScreenState extends State<FastTrackRulesQuizScreen> {
  int _index = 0;
  int _correct = 0;
  String? _picked;
  bool _revealed = false;
  bool _done = false;

  FtQuizItem get _item => widget.items[_index];

  Future<void> _pick(String option) async {
    if (_revealed || _done) return;
    HapticFeedback.selectionClick();
    final ok = option == _item.correctLabel;
    setState(() {
      _picked = option;
      _revealed = true;
      if (ok) _correct++;
    });
    if (ok) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _next() async {
    if (_index >= widget.items.length - 1) {
      final pct = ((_correct / widget.items.length) * 100).round();
      final passed = pct >= 85;
      await context.read<AppState>().setFtMasteryResult(passed: passed, scorePct: pct);
      if (!mounted) return;
      setState(() => _done = true);
      return;
    }
    setState(() {
      _index++;
      _picked = null;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);

    if (_done) {
      final pct = ((_correct / widget.items.length) * 100).round();
      final passed = pct >= 85;
      return PremiumScaffold(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context, passed),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: passed ? AppColors.emerald : AppColors.coral,
                  boxShadow: [
                    BoxShadow(
                      color: (passed ? AppColors.emerald : AppColors.coral).withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  passed ? Icons.verified_rounded : Icons.refresh_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                passed ? l.ftMasteryPassTitle : l.ftMasteryFailTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.15),
              ),
              const SizedBox(height: 10),
              Text(
                l.ftMasteryScore(_correct, widget.items.length, pct),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Text(
                passed ? l.ftMasteryPassBody : l.ftMasteryFailBody,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4),
              ),
              const Spacer(),
              NeonButton(
                label: passed ? l.ftGoExam : l.ftRetryRules,
                icon: passed ? Icons.flag_rounded : Icons.replay_rounded,
                onPressed: () => Navigator.pop(context, passed),
              ),
            ],
          ),
        ),
      );
    }

    final progress = (_index + 1) / widget.items.length;

    return PremiumScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close_rounded),
                ),
                Expanded(
                  child: Text(
                    l.ftRulesTestTitle,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  '${_index + 1}/${widget.items.length}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted),
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
                color: AppColors.blue,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.ftRulesTestHint,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.amber,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _item.prompt,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _item.subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.35),
                  ),
                  const Spacer(),
                  ..._item.options.map((opt) {
                    Color border = AppColors.stroke;
                    Color bg = AppColors.surface;
                    Color fg = AppColors.ink;
                    if (_revealed) {
                      if (opt == _item.correctLabel) {
                        border = AppColors.emerald;
                        bg = AppColors.emeraldDim;
                        fg = AppColors.emerald;
                      } else if (opt == _picked) {
                        border = AppColors.coral;
                        bg = AppColors.coralDim;
                        fg = AppColors.coral;
                      }
                    } else if (opt == _picked) {
                      border = AppColors.blue;
                      bg = AppColors.blueDim;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _pick(opt),
                          borderRadius: BorderRadius.circular(18),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: border, width: 1.6),
                            ),
                            child: Text(
                              opt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: fg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_revealed) ...[
                    const SizedBox(height: 6),
                    NeonButton(
                      label: _index >= widget.items.length - 1 ? l.ftSeeResult : l.next,
                      onPressed: _next,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

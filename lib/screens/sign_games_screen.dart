import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/sign_art.dart';
import 'signs_atlas_screen.dart';

class SignGamesScreen extends StatelessWidget {
  const SignGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return PremiumScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Expanded(
                child: Text(
                  l.signGamesTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GameCard(
            title: l.signsAtlasTitle,
            subtitle: l.signsAtlasTileSub,
            gradient: AppColors.neonGradient,
            glow: AppColors.neonGlow,
            icon: Icons.map_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignsAtlasScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _GameCard(
            title: l.guessSign,
            subtitle: l.guessSignSub,
            gradient: AppColors.orangeGradient,
            glow: AppColors.orangeGlow,
            icon: Icons.help_outline_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _GuessSignGame()),
            ),
          ),
          const SizedBox(height: 14),
          _GameCard(
            title: l.fourSigns,
            subtitle: l.fourSignsSub,
            gradient: AppColors.electricGradient,
            glow: AppColors.electricGlow,
            icon: Icons.grid_view_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _FourSignsGame()),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.glow,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Gradient gradient;
  final Color glow;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: glow, blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuessSignGame extends StatefulWidget {
  const _GuessSignGame();

  @override
  State<_GuessSignGame> createState() => _GuessSignGameState();
}

class _GuessSignGameState extends State<_GuessSignGame> {
  final _rng = math.Random();
  Chapter? _target;
  List<Chapter> _options = const [];
  int? _picked;
  int _score = 0;
  int _round = 0;
  bool _dealt = false;
  static const _total = 8;

  List<Chapter> get _chapters => context.read<AppState>().chapters;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dealt && _chapters.length >= 4) {
      _dealt = true;
      _deal();
    }
  }

  void _deal() {
    final pool = List<Chapter>.from(_chapters);
    if (pool.length < 4) return;
    pool.shuffle(_rng);
    _target = pool.first;
    _options = pool.take(4).toList()..shuffle(_rng);
    _picked = null;
    _round++;
  }

  void _pick(int index) {
    if (_picked != null || _target == null) return;
    HapticFeedback.selectionClick();
    final ok = _options[index].id == _target!.id;
    setState(() {
      _picked = index;
      if (ok) _score++;
    });
  }

  void _next() {
    if (_round >= _total) {
      _showResult();
      return;
    }
    setState(_deal);
  }

  void _showResult() {
    final l = L10n.read(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.scoreLabel(_score, _total),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            NeonButton(
              label: l.playAgain,
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _score = 0;
                  _round = 0;
                  _deal();
                });
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(l.close),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final target = _target;
    if (_chapters.length < 4 || target == null || _options.isEmpty) {
      return PremiumScaffold(
        child: Center(child: Text(l.noChaptersFound)),
      );
    }
    String nameOf(Chapter c) => l.isEn ? c.nameEn : c.nameIt;

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
                  child: Text(
                    l.guessSign,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                Text(
                  '$_round/$_total',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SignArt(chapterId: target.id, label: l.whichSign, height: 170),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = _options[i];
                final selected = _picked == i;
                final correct = c.id == target.id;
                Color border = AppColors.strokeStrong;
                Color? bg;
                if (_picked != null) {
                  if (correct) {
                    border = AppColors.neon;
                    bg = AppColors.neonDim;
                  } else if (selected) {
                    border = AppColors.red;
                    bg = AppColors.redDim;
                  }
                }
                return PremiumCard(
                  padding: const EdgeInsets.all(14),
                  borderColor: border.withValues(alpha: 0.5),
                  onTap: () => _pick(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: bg == null ? EdgeInsets.zero : const EdgeInsets.all(4),
                    child: Text(
                      nameOf(c),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_picked != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: NeonButton(
                label: _round >= _total ? l.seeResult : l.next,
                onPressed: _next,
              ),
            ),
        ],
      ),
    );
  }
}

class _FourSignsGame extends StatefulWidget {
  const _FourSignsGame();

  @override
  State<_FourSignsGame> createState() => _FourSignsGameState();
}

class _FourSignsGameState extends State<_FourSignsGame> {
  final _rng = math.Random();
  Chapter? _target;
  List<Chapter> _options = const [];
  int? _picked;
  int _score = 0;
  int _round = 0;
  bool _dealt = false;
  static const _total = 8;

  List<Chapter> get _chapters => context.read<AppState>().chapters;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dealt && _chapters.length >= 4) {
      _dealt = true;
      _deal();
    }
  }

  void _deal() {
    final pool = List<Chapter>.from(_chapters)..shuffle(_rng);
    _target = pool.first;
    _options = pool.take(4).toList()..shuffle(_rng);
    _picked = null;
    _round++;
  }

  void _pick(int index) {
    if (_picked != null || _target == null) return;
    HapticFeedback.selectionClick();
    final ok = _options[index].id == _target!.id;
    setState(() {
      _picked = index;
      if (ok) _score++;
    });
  }

  void _next() {
    if (_round >= _total) {
      _showResult();
      return;
    }
    setState(_deal);
  }

  void _showResult() {
    final l = L10n.read(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.scoreLabel(_score, _total),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            NeonButton(
              label: l.playAgain,
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _score = 0;
                  _round = 0;
                  _deal();
                });
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(l.close),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final target = _target;
    if (_chapters.length < 4 || target == null || _options.isEmpty) {
      return PremiumScaffold(
        child: Center(child: Text(l.noChaptersFound)),
      );
    }
    final prompt = l.isEn ? target.nameEn : target.nameIt;

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
                  child: Text(
                    l.fourSigns,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                Text(
                  '$_round/$_total',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
            child: PremiumCard(
              borderColor: AppColors.electric.withValues(alpha: 0.3),
              child: Column(
                children: [
                  Text(
                    l.pickMatchingSign,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: _options.length,
              itemBuilder: (context, i) {
                final c = _options[i];
                final selected = _picked == i;
                final correct = c.id == target.id;
                Color border = AppColors.stroke;
                if (_picked != null) {
                  if (correct) {
                    border = AppColors.neon;
                  } else if (selected) {
                    border = AppColors.red;
                  }
                }
                return GestureDetector(
                  onTap: () => _pick(i),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SignArt(
                      chapterId: c.id,
                      label: ' ',
                      height: 160,
                    ),
                  ),
                );
              },
            ),
          ),
          if (_picked != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: NeonButton(
                label: _round >= _total ? l.seeResult : l.next,
                onPressed: _next,
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n(state.lang);
    final stats = state.stats;
    final weak = state.weakTopics;
    final scores = stats.weekAccuracy;
    final hasData = stats.totalAnswers > 0;

    final canPop = Navigator.of(context).canPop();

    return PremiumScaffold(
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          if (canPop)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
          Text(
            l.statsTitle,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.statsSubtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TabChip(label: l.tabGeneral, selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _TabChip(label: l.tabWeak, selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
              const SizedBox(width: 8),
              _TabChip(label: l.tabTrend, selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
            ],
          ),
          const SizedBox(height: 18),
          PremiumCard(
            glow: AppColors.neonGlow,
            borderColor: AppColors.neon.withValues(alpha: 0.25),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.accuracyLabel,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hasData ? '${(stats.accuracy * 100).round()}%' : '—',
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              l.answersCount(stats.totalAnswers),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.electricGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: AppColors.electricGlow, blurRadius: 14, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${(stats.readiness * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        l.ready,
                        style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_tab == 0 || _tab == 2)
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l.last7Days,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        '🔥 ${l.streakDays(stats.streak)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.orange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 170,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 1,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (v) => const FlLine(
                            color: AppColors.stroke,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (v, _) {
                                const days = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
                                final i = v.toInt();
                                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                                return Text(
                                  days[i],
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < scores.length; i++)
                                FlSpot(i.toDouble(), scores[i]),
                            ],
                            isCurved: true,
                            color: AppColors.neon,
                            barWidth: 3.5,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.neonSoft,
                                strokeWidth: 0,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.neon.withValues(alpha: 0.4),
                                  AppColors.neon.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!hasData)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l.completeFirstQuiz,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ),
                ],
              ),
            ),
          if (_tab == 0 || _tab == 1) ...[
            const SizedBox(height: 18),
            Text(
              l.hardestTopics,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (weak.isEmpty)
              PremiumCard(
                child: Row(
                  children: [
                    const Icon(Icons.insights_rounded, color: AppColors.electricSoft),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.weakHint,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...weak.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PremiumCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.topicName(t),
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text(
                              '${(t.accuracy * 100).round()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: t.accuracy < 0.65 ? AppColors.red : AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${t.nameIt == l.topicName(t) ? t.nameEn : t.nameIt} · ${l.answersCount(t.seen)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: t.accuracy,
                            minHeight: 7,
                            backgroundColor: AppColors.navyElevated,
                            color: t.accuracy < 0.65 ? AppColors.red : AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 6),
          PremiumCard(
            borderColor: AppColors.neon.withValues(alpha: 0.3),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.neonGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.event_repeat_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.nextReview,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        stats.totalAnswers == 0
                            ? l.startQuizForReview
                            : l.spacedRepetition(stats.estDaysLeft),
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.passProbability((stats.readiness * 100).round()),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 22),
          Text(
            l.examHistory,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (state.examHistory.isEmpty)
            PremiumCard(
              child: Text(
                l.noExamsYet,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            )
          else
            ...state.examHistory.take(8).map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PremiumCard(
                  padding: const EdgeInsets.all(14),
                  borderColor: (e.passed ? AppColors.neon : AppColors.red)
                      .withValues(alpha: 0.28),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (e.passed ? AppColors.neon : AppColors.red)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          e.passed ? Icons.verified_rounded : Icons.cancel_rounded,
                          color: e.passed ? AppColors.neonSoft : AppColors.redSoft,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.passed ? l.examPassedShort : l.examFailedShort,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              l.examHistoryLine(e.correct, e.wrong),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${e.createdAt.day.toString().padLeft(2, '0')}/'
                        '${e.createdAt.month.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.electricGradient : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

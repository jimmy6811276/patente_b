import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_layout.dart';
import '../widgets/design_system.dart';
import '../widgets/premium_scaffold.dart';
import '../widgets/question_image.dart';
import 'quiz_screen.dart';

/// Browse every unique ministerial sign — feature competitors ship as “Segnali”.
class SignsAtlasScreen extends StatefulWidget {
  const SignsAtlasScreen({super.key});

  @override
  State<SignsAtlasScreen> createState() => _SignsAtlasScreenState();
}

class _SignsAtlasScreenState extends State<SignsAtlasScreen> {
  Future<List<SignAtlasItem>>? _future;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= context.read<AppState>().store.distinctSignImages();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = L10n(state.lang);

    return PremiumScaffold(
      safeBottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: DsScreenHeader(
                    title: l.signsAtlasTitle,
                    subtitle: l.signsAtlasSubtitle,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: l.searchSign,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.stroke),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SignAtlasItem>>(
              future: _future,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data!
                    .where((s) {
                      if (_query.isEmpty) return true;
                      return s.image.toLowerCase().contains(_query) ||
                          s.chapterNameIt.toLowerCase().contains(_query) ||
                          s.chapterNameEn.toLowerCase().contains(_query);
                    })
                    .toList();
                if (items.isEmpty) {
                  return Center(child: Text(l.noSignsFound));
                }
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    AppLayout.bottomClearance(context),
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return _SignTile(
                      item: item,
                      chapterLabel: item.chapterName(state.lang.isEnglish),
                      quizLabel: l.questionsCount(item.questionCount),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            title: item.chapterName(state.lang.isEnglish),
                            chapterId: item.chapterId,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SignTile extends StatelessWidget {
  const _SignTile({
    required this.item,
    required this.chapterLabel,
    required this.quizLabel,
    required this.onTap,
  });

  final SignAtlasItem item;
  final String chapterLabel;
  final String quizLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final path = QuestionImage.assetPathFor(item.image);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppLayout.cardRadius),
            border: Border.all(color: AppColors.stroke),
            boxShadow: const [
              BoxShadow(color: Color(0x100B1220), blurRadius: 12, offset: Offset(0, 5)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: path == null
                        ? const Icon(Icons.signpost_rounded, color: AppColors.amber)
                        : Image.asset(
                            path,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.signpost_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  chapterLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
                Text(
                  quizLabel,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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

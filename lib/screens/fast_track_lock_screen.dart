import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_scaffold.dart';
import 'fast_track_screen.dart';

/// Credential gate in front of [FastTrackScreen].
///
/// A successful unlock is remembered on this device until it is explicitly
/// locked again from Settings, so the owner is not asked on every tap.
class FastTrackLockScreen extends StatefulWidget {
  const FastTrackLockScreen({super.key});

  @override
  State<FastTrackLockScreen> createState() => _FastTrackLockScreenState();
}

class _FastTrackLockScreenState extends State<FastTrackLockScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passFocus = FocusNode();

  bool _obscure = true;
  bool _busy = false;
  String? _error;
  int _failures = 0;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  /// Each wrong attempt adds a delay, making repeated guessing impractical.
  Duration get _penalty => Duration(
        milliseconds: _failures <= 2 ? 300 : (_failures * 700).clamp(300, 5000),
      );

  Future<void> _submit() async {
    if (_busy) return;
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Inserisci nome utente e password.');
      return;
    }

    FocusScope.of(context).unfocus();
    final appState = context.read<AppState>();
    setState(() {
      _busy = true;
      _error = null;
    });

    if (_failures > 0) await Future<void>.delayed(_penalty);

    final ok = await appState.unlockFastTrack(
      username: username,
      password: password,
    );

    if (!mounted) return;

    if (ok) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FastTrackScreen()),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _busy = false;
      _failures++;
      _error = 'Credenziali non valide. Riprova.';
      _passCtrl.clear();
    });
    _passFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final locked = _failures >= 5;

    return PremiumScaffold(
      child: Column(
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
                    'Area riservata',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              physics: const BouncingScrollPhysics(),
              children: [
                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.neon.withValues(alpha: 0.28),
                          AppColors.electric.withValues(alpha: 0.28),
                        ],
                      ),
                      border: Border.all(color: AppColors.neon.withValues(alpha: 0.4)),
                      boxShadow: const [
                        BoxShadow(color: AppColors.neonGlow, blurRadius: 30, offset: Offset(0, 10)),
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded, color: AppColors.neonSoft, size: 40),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Fast Track',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Questa sezione è privata.\nInserisci le credenziali fornite dall\'amministratore.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                PremiumCard(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  borderColor: AppColors.neon.withValues(alpha: 0.22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Nome utente'),
                      _GateField(
                        controller: _userCtrl,
                        hint: 'username',
                        icon: Icons.person_outline_rounded,
                        enabled: !_busy,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Password'),
                      _GateField(
                        controller: _passCtrl,
                        hint: '••••••••',
                        icon: Icons.key_rounded,
                        focusNode: _passFocus,
                        enabled: !_busy,
                        obscure: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        trailing: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.redSoft, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppColors.redSoft,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (locked) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Troppi tentativi. Attendi qualche secondo prima di riprovare.',
                          style: TextStyle(
                            color: AppColors.orange.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      NeonButton(
                        label: _busy ? 'Verifica…' : 'Sblocca',
                        icon: _busy ? Icons.hourglass_top_rounded : Icons.lock_open_rounded,
                        gradient: AppColors.neonGradient,
                        glow: AppColors.neonGlow,
                        onPressed: _busy ? () {} : _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Accesso verificato sul dispositivo · nessun dato inviato',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _GateField extends StatelessWidget {
  const _GateField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.focusNode,
    this.enabled = true,
    this.obscure = false,
    this.trailing,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final FocusNode? focusNode;
  final bool enabled;
  final bool obscure;
  final Widget? trailing;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscure,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 20, color: AppColors.neonSoft),
        suffixIcon: trailing,
        filled: true,
        fillColor: AppColors.navyElevated.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neon, width: 1.4),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/app_state.dart';
import 'screens/app_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF3F6FB),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PatenteBApp());
}

class PatenteBApp extends StatelessWidget {
  const PatenteBApp({super.key, this.state});

  /// Optional injected state — used by widget tests with an in-memory DB.
  final AppState? state;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => (state ?? AppState())..init(),
      child: Consumer<AppState>(
        builder: (context, appState, _) => MaterialApp(
          title: 'Patente B',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(readable: appState.readableFont),
          locale: Locale(appState.lang.code),
          supportedLocales: const [Locale('it'), Locale('en')],
          home: const AppShell(),
        ),
      ),
    );
  }
}

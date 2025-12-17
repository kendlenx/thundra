import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: ThundraApp()));
}

class ThundraApp extends StatelessWidget {
  const ThundraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'THUNDRA',
      theme: AppTheme.cupertinoDark,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Theme(
            data: AppTheme.materialDark(context),
            child: DefaultTextStyle(
              style: AppTheme.cupertinoDark.textTheme.textStyle,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
      home: const AppShell(),
    );
  }
}

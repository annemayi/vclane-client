import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vclane_client/core/theme/app_theme.dart' as app_theme;
import 'package:vclane_client/app/router.dart';

class VclaneApp extends ConsumerWidget {
  const VclaneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter(ref);
    return MaterialApp.router(
      title: 'VC-LANE',
      debugShowCheckedModeBanner: false,
      theme: app_theme.lightTheme,
      routerConfig: router,
    );
  }
}

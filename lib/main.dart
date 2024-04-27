import 'package:blackjack/components/app_llifecycle.dart';
import 'package:blackjack/components/palette.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'blackjack_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Blackjack'),
                  TextButton(
                    onPressed: () => context.go('/play'),
                    child: const Text('play'),
                  ),
                ],
              ),
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
        routes: [
          GoRoute(
            path: 'play',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: GameWidget(game: BlackjackGame()),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
    ],
  );

  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          Provider(
            create: (context) => Palette(),
          ),
        ],
        child: Builder(
          builder: (context) {
            final palette = context.watch<Palette>();

            return MaterialApp.router(
              title: 'Blackjack Demo',
              theme: ThemeData.from(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: palette.darkPen,
                  background: palette.backgroundMain,
                ),
                textTheme: TextTheme(
                  bodyMedium: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              routeInformationProvider: _router.routeInformationProvider,
              routeInformationParser: _router.routeInformationParser,
              routerDelegate: _router.routerDelegate,
            );
          },
        ),
      ),
    );
  }
}

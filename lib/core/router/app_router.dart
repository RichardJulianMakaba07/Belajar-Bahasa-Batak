import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../di/injection.dart';
import '../../pages/dictionary_page.dart';
import '../../pages/home_page.dart';
import '../../pages/kalimat_page.dart';
import '../../pages/learned_words_page.dart';
import '../../pages/new_word_search_page.dart';
import '../../pages/profil_page.dart';
import '../../pages/quiz1_page.dart';
import '../../pages/vocabulary_exercise.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => HomePage(
                  onLearnWord: () => context.go('/dictionary'),
                  onStartPractice: () => context.go('/exercise'),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dictionary',
                builder: (context, state) => const DictionaryPage(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'learned',
                    builder: (context, state) => const LearnedWordsPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'new',
                    builder: (context, state) => const NewWordSearchPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exercise',
                builder: (context, state) => const VocabularyExercisePage(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'quiz',
                    builder: (context, state) => const Quiz1Page(),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'sentence',
                    builder: (context, state) => const KalimatPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => BlocProvider(
                  create: (_) => sl<ProfileCubit>(),
                  child: const ProfilPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _AppShell({required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width>= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWide ? 760 : double.infinity,
          ),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

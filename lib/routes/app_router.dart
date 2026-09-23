import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/domain/repositories/auth_repository_interface.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';
import '../features/pets/presentation/pages/pets_page.dart';
import '../features/pets/presentation/pages/add_pet_page.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final result = authState.valueOrNull;

      final isLoggedIn = result != null && result.isAuthenticated;
      final user = result?.user;
      final isProfileComplete =
          user != null && user.city.isNotEmpty && user.state.isNotEmpty;
      final isBanned = result?.status == ProfileStatus.banned;
      final isInactive = result?.status == ProfileStatus.inactive;
      final isDeleted = result?.status == ProfileStatus.deleted;

      final currentPath = state.matchedLocation;
      final isAuthRoute =
          currentPath == RouteNames.login || currentPath == RouteNames.register;

      // Usuário banido: sempre redirecionar para login com mensagem
      if (isBanned || isInactive || isDeleted) {
        return RouteNames.login;
      }

      // Sem sessão válida: só pode acessar auth routes
      if (!isLoggedIn && !isAuthRoute) {
        return RouteNames.login;
      }

      // Sessão válida mas perfil incompleto (sem cidade/estado): ir para onboarding
      if (isLoggedIn && !isProfileComplete && !isAuthRoute) {
        return RouteNames.onboarding;
      }

      // Sessão válida com perfil completo em rota de auth: vai para home
      if (isLoggedIn && isAuthRoute) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const _SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (context, state) => const _PlaceholderPage(title: 'Home'),
      ),
      GoRoute(
        path: RouteNames.pets,
        name: RouteNames.pets,
        builder: (context, state) => const PetsPage(),
      ),
      GoRoute(
        path: RouteNames.addPet,
        name: RouteNames.addPet,
        builder: (context, state) => const AddPetPage(),
      ),
      GoRoute(
        path: RouteNames.feed,
        name: RouteNames.feed,
        builder: (context, state) => const _PlaceholderPage(title: 'Feed'),
      ),
      GoRoute(
        path: RouteNames.matches,
        name: RouteNames.matches,
        builder: (context, state) => const _PlaceholderPage(title: 'Matches'),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        builder: (context, state) => const _PlaceholderPage(title: 'Perfil'),
      ),
    ],
  );
});

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

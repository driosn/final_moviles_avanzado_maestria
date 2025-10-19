import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/admin_home_page.dart';
import '../../features/auth/presentation/pages/cliente_home_page.dart';
import '../../features/auth/presentation/pages/gestor_home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/stores/presentation/pages/stores_list_page.dart';
import '../../features/users/presentation/pages/store_assignment_page.dart';
import '../../features/users/presentation/pages/user_management_page.dart';
import '../injection/injection_container.dart';

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String stores = '/stores';
  static const String userManagement = '/user-management';
  static const String storeAssignment = '/store-assignment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage(), settings: settings);
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpPage(), settings: settings);
      case home:
        return MaterialPageRoute(builder: (_) => const HomeWrapper(), settings: settings);
      case stores:
        return MaterialPageRoute(
          builder: (_) => const AdminOnlyWrapper(child: StoresListPage()),
          settings: settings,
        );
      case userManagement:
        return MaterialPageRoute(
          builder: (_) => const AdminOnlyWrapper(child: UserManagementPage()),
          settings: settings,
        );
      case storeAssignment:
        return MaterialPageRoute(
          builder: (_) => const AdminOnlyWrapper(child: StoreAssignmentPage()),
          settings: settings,
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage(), settings: settings);
    }
  }
}

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (state is AuthAuthenticated) {
            return _buildHomePageForUser(state.user);
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }

  Widget _buildHomePageForUser(User user) {
    switch (user.role) {
      case UserRole.admin:
        return const AdminHomePage();
      case UserRole.gestorTienda:
        return const GestorHomePage();
      case UserRole.cliente:
        return const ClienteHomePage();
    }
  }
}

class AdminOnlyWrapper extends StatelessWidget {
  final Widget child;

  const AdminOnlyWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is AuthAuthenticated && state.user.role == UserRole.admin) {
          return child;
        } else {
          // Si no está autenticado o no es admin, redirigir al login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

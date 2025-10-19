import 'package:final_movil_aplicaciones_avanzado/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:final_movil_aplicaciones_avanzado/features/products/presentation/bloc/products_bloc.dart';
import 'package:final_movil_aplicaciones_avanzado/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection/injection_container.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthBloc>()),
        BlocProvider(create: (context) => sl<StoresBloc>()),
        BlocProvider(create: (context) => sl<ProductsBloc>()),
      ],
      child: MaterialApp(
        title: 'Sistema de Autenticación',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.login,
      ),
    );
  }
}

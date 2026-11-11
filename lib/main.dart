
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/sensor_cubit.dart';
import 'pages/dashboard_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const AplikasiSiagaBencana(),
  );
}

class AplikasiSiagaBencana extends StatelessWidget {
  const AplikasiSiagaBencana({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SensorCubit(),

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: 'SIAGA BENCANA',

        theme: AppTheme.lightTheme,

        home: const DashboardPage(),
      ),
    );
  }
}

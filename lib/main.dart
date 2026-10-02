import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/features/auth/presentation/cadastrar.dart';
import 'package:tcc_mobile/features/auth/presentation/entrar.dart';
import 'package:tcc_mobile/features/auth/presentation/tela_inicial.dart';
import 'package:tcc_mobile/features/routines/presentation/rotinas.dart';
import 'package:tcc_mobile/features/analytics/presentation/graficos.dart';
import 'package:tcc_mobile/features/home/presentation/home.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelhos.dart';
import 'package:tcc_mobile/features/settings/presentation/configuracoes.dart';

void main() {
  runApp(const FhiveApp());
}

class FhiveApp extends StatelessWidget {
  const FhiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fhive',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data,

      initialRoute: '/inicio',

      routes: {
        '/inicio': (context) => const TelaInicial(),
        '/home': (context) => const TelaHome(),
        '/aparelhos': (context) => const TelaAparelhos(),
        '/graficos': (context) => const TelaGraficos(),
        '/configuracoes': (context) => const TelaConfiguracoes(),
        '/rotinas': (context) => const TelaRotinas(),
        '/entrar': (context) => const TelaDeLogin(),
        '/cadastrar': (context) => const TelaDeCadastro(),
      },
    );
  }
}

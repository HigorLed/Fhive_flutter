import 'package:flutter/material.dart';
import 'package:tcc_mobile/widget/rotinas.dart';
import 'package:tcc_mobile/widget/graficos.dart';
import 'package:tcc_mobile/widget/home.dart';
import 'package:tcc_mobile/widget/aparelhos.dart';
import 'package:tcc_mobile/widget/confi.dart';

void main() {
  runApp(const FhiveApp());
}

class FhiveApp extends StatelessWidget {
  const FhiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/home',

      routes: {
        '/home': (context) => const TelaHome(),
        '/aparelhos': (context) => const TelaAparelhos(),
        '/graficos': (context) => const TelaGraficos(),
        '/configuracoes': (context) => const TelaConfiguracoes(),
        '/rotinas': (context) => const TelaRotinas(),
      },
    );
  }
}
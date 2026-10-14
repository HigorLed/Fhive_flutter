import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/features/auth/presentation/cadastrar.dart';
import 'package:tcc_mobile/features/auth/presentation/entrar.dart';
import 'package:tcc_mobile/features/auth/presentation/tela_inicial.dart';
import 'package:tcc_mobile/features/routines/presentation/rotinas.dart';
import 'package:tcc_mobile/features/analytics/presentation/graficos.dart';
import 'package:tcc_mobile/features/home/presentation/home.dart';
import 'package:tcc_mobile/features/devices/presentation/aparelhos.dart';
import 'package:tcc_mobile/features/settings/presentation/configuracoes.dart';
import 'package:tcc_mobile/features/settings/presentation/conta.dart';
import 'package:tcc_mobile/features/settings/presentation/ajuda.dart';
import 'package:tcc_mobile/shared/widgets/fundo_navegacao_sistema.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Mantém a navegação do sistema no tom da barra inferior do Fhive
  // em versões do Android que permitem definir a cor diretamente.
  // No modo edge-to-edge (Android 15+), FundoNavegacaoSistema pinta essa
  // área no MaterialApp para cobrir todas as rotas.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.surfaceLight,
      systemNavigationBarDividerColor: AppColors.surfaceLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
      // Aplica o fundo da navegação do sistema a todas as rotas, incluindo
      // telas secundárias de gráficos e controle de aparelhos.
      builder: (context, child) => FundoNavegacaoSistema(
        child: child ?? const SizedBox.shrink(),
      ),

      initialRoute: '/inicio',

      routes: {
        '/inicio': (context) => const TelaInicial(),
        '/home': (context) => const TelaHome(),
        '/aparelhos': (context) => const TelaAparelhos(),
        '/graficos': (context) => const TelaGraficos(),
        '/configuracoes': (context) => const TelaConfiguracoes(),
        '/conta': (context) => const TelaConta(),
        '/ajuda': (context) => const TelaAjuda(),
        '/rotinas': (context) => const TelaRotinas(),
        '/entrar': (context) => const TelaDeLogin(),
        '/cadastrar': (context) => const TelaDeCadastro(),
      },
    );
  }
}

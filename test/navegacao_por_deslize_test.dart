import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tcc_mobile/shared/widgets/navegacao_por_deslize.dart';

void main() {
  Widget pagina(int indice, String titulo) => NavegacaoPorDeslize(
        itemSelecionado: indice,
        child: Scaffold(body: Center(child: Text(titulo))),
      );

  testWidgets('deslizar para a esquerda avança e para a direita retorna',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/home',
        routes: {
          '/home': (_) => pagina(0, 'Início'),
          '/aparelhos': (_) => pagina(1, 'Aparelhos'),
          '/graficos': (_) => pagina(2, 'Gráficos'),
          '/rotinas': (_) => pagina(3, 'Rotinas'),
          '/configuracoes': (_) => pagina(4, 'Configurações'),
        },
      ),
    );

    expect(find.text('Início'), findsOneWidget);
    await tester.drag(find.byType(Scaffold), const Offset(-180, 0));
    await tester.pumpAndSettle();
    expect(find.text('Aparelhos'), findsOneWidget);

    await tester.drag(find.byType(Scaffold), const Offset(180, 0));
    await tester.pumpAndSettle();
    expect(find.text('Início'), findsOneWidget);
  });
}

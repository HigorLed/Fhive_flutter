import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';

/// Tutorial do Fhive: apresenta cada função principal do aplicativo com um
/// resumo e um passo a passo curto de como utilizá-la.
class TelaTutorial extends StatefulWidget {
  const TelaTutorial({super.key});

  @override
  State<TelaTutorial> createState() => _TelaTutorialState();
}

class _TelaTutorialState extends State<TelaTutorial> {
  final PageController controller = PageController();

  int paginaAtual = 0;

  static const List<_TutorialPagina> paginas = [
    _TutorialPagina(
      titulo: 'Bem-vindo ao Fhive',
      icone: Icons.home_outlined,
      resumo:
          'O Fhive reúne o controle da sua casa inteligente em um só lugar. '
          'Veja as funções principais e como usar cada uma.',
      tituloPassos: 'Como se movimentar',
      passos: [
        'Use a barra inferior para alternar entre Início, Aparelhos, '
            'Gráficos, Rotinas e Configurações.',
        'Também é possível arrastar a tela para a esquerda ou para a direita '
            'para trocar de aba.',
        'Para rever este guia, toque no cartão "Tutorial" na tela Início.',
      ],
    ),
    _TutorialPagina(
      titulo: 'Início',
      icone: Icons.dashboard_outlined,
      resumo:
          'O painel da sua casa: atalhos para o que você mais usa e seus '
          'aparelhos favoritos à mão.',
      passos: [
        'Toque em "Conexões" para ver a lista de aparelhos cadastrados.',
        'Toque em "Energia" para acompanhar os gastos de energia.',
        'Em "Saída de som", configure o áudio da sua TV (é preciso ter uma '
            'TV cadastrada).',
        'Os aparelhos favoritos aparecem em "Favoritos", com acesso direto '
            'ao controle.',
      ],
    ),
    _TutorialPagina(
      titulo: 'Aparelhos',
      icone: Icons.devices_outlined,
      resumo:
          'Cadastre seus aparelhos e organize-os por local, como sala, '
          'quarto ou cozinha.',
      passos: [
        'Toque no botão + para criar um aparelho. O cadastro tem 4 etapas: '
            'identificação, detalhes, conexão e revisão.',
        'Use "Locais" para filtrar por cômodo ou criar um novo local.',
        'Toque na estrela do cartão para favoritar o aparelho.',
        'Toque no cartão para abrir o controle e as informações do aparelho.',
      ],
    ),
    _TutorialPagina(
      titulo: 'Controle do aparelho',
      icone: Icons.power_settings_new,
      resumo:
          'Ligue, desligue e ajuste cada aparelho. As opções mudam conforme '
          'o tipo: volume e canal na TV, temperatura no ar-condicionado.',
      passos: [
        'Abra o aparelho pela tela Aparelhos ou pelos Favoritos.',
        'Use o botão principal para ligar ou desligar.',
        'Ajuste volume, canal ou temperatura nos controles rápidos.',
        'Ative opções extras, como o desligamento automático, nos '
            'interruptores.',
      ],
      observacao:
          'Os comandos físicos ainda dependem da integração com o aparelho.',
    ),
    _TutorialPagina(
      titulo: 'Rotinas',
      icone: Icons.auto_awesome,
      resumo:
          'Programe horários e ações para um aparelho e deixe as tarefas do '
          'dia a dia mais práticas.',
      passos: [
        'Toque em "Adicionar rotina" (cadastre um aparelho antes).',
        'Informe o nome, escolha o aparelho, os dias da semana, o horário e '
            'as ações. Depois, salve.',
        'No ícone ⋮ de cada rotina, você edita, ativa, desativa ou remove.',
        'Use o seletor de local, no topo, para ver só as rotinas de um '
            'cômodo.',
      ],
      observacao:
          'As rotinas ficam salvas na sua conta. A execução física dos '
          'comandos ainda não está disponível.',
    ),
    _TutorialPagina(
      titulo: 'Gráficos',
      icone: Icons.bar_chart,
      resumo:
          'Acompanhe energia, uso e eficiência dos seus aparelhos para '
          'entender e economizar.',
      passos: [
        'Todos os cômodos que têm aparelhos com gráficos aparecem na lista, '
            'cada um com os seus aparelhos.',
        'Toque em um aparelho para abrir energia, horas usadas, eficiência '
            'e recomendações.',
        'Nos gráficos de linha, use as abas Semanal, Mensal e Geral para '
            'mudar o período.',
      ],
      observacao:
          'Enquanto não houver telemetria real, alguns valores são '
          'demonstrativos.',
    ),
    _TutorialPagina(
      titulo: 'Conta e ajuda',
      icone: Icons.settings_outlined,
      resumo:
          'Gerencie seu perfil, ajuste preferências e encontre respostas '
          'para as dúvidas mais comuns.',
      passos: [
        'Em "Minha conta", edite seu nome, e-mail e senha.',
        'Ative ou desative notificações, sincronização de favoritos e '
            'sugestões de função.',
        'Em "Ajuda", veja as respostas para as dúvidas frequentes.',
        'Use "Sair do Fhive" para encerrar a sessão.',
      ],
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool get _ultimaPagina => paginaAtual == paginas.length - 1;

  void avancar() {
    if (!_ultimaPagina) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void voltar() {
    if (paginaAtual > 0) {
      controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.pageTop,
      ),
      child: Container(
        width: double.infinity,
        height: tamanho.height * 0.82,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: paginas.length,
                    onPageChanged: (index) {
                      setState(() => paginaAtual = index);
                    },
                    itemBuilder: (context, index) => _conteudo(paginas[index]),
                  ),
                ),
                _rodape(),
              ],
            ),

            // Contador de páginas.
            Positioned(
              top: AppSpacing.xl,
              left: AppSpacing.xl,
              child: Text(
                '${paginaAtual + 1} de ${paginas.length}',
                style: AppTextStyles.caption.copyWith(color: AppColors.accent),
              ),
            ),

            // Fechar.
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: IconButton(
                tooltip: 'Fechar tutorial',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rodape() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          // O FittedBox impede estouro caso a tela seja estreita.
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(fit: BoxFit.scaleDown, child: _indicadores()),
            ),
          ),
          if (paginaAtual > 0)
            IconButton(
              tooltip: 'Voltar',
              onPressed: voltar,
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.accent,
                size: 21,
              ),
            ),
          TextButton(
            onPressed: avancar,
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _ultimaPagina ? 'Finalizar' : 'Avançar',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  _ultimaPagina ? Icons.check : Icons.arrow_forward,
                  color: AppColors.accent,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteudo(_TutorialPagina pagina) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        56,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Icon(pagina.icone, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  pagina.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            pagina.resumo,
            style: AppTextStyles.body.copyWith(
              color: AppColors.white,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            pagina.tituloPassos,
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Column(
              children: [
                for (var i = 0; i < pagina.passos.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == pagina.passos.length - 1 ? 0 : AppSpacing.md,
                    ),
                    child: _passo(i + 1, pagina.passos[i]),
                  ),
              ],
            ),
          ),
          if (pagina.observacao != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    pagina.observacao!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _passo(int numero, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$numero',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            texto,
            style: AppTextStyles.body.copyWith(
              color: AppColors.white,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _indicadores() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(paginas.length, (index) {
        final ativo = index == paginaAtual;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          width: ativo ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: ativo
                ? AppColors.accent
                : AppColors.white.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(AppRadius.chip),
          ),
        );
      }),
    );
  }
}

class _TutorialPagina {
  final String titulo;
  final IconData icone;
  final String resumo;
  final String tituloPassos;
  final List<String> passos;
  final String? observacao;

  const _TutorialPagina({
    required this.titulo,
    required this.icone,
    required this.resumo,
    required this.passos,
    this.tituloPassos = 'Como usar',
    this.observacao,
  });
}

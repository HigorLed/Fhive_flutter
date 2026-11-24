import 'package:flutter/material.dart';
import 'package:tcc_mobile/shared/widgets/dialogo_texto.dart';
import 'package:tcc_mobile/shared/widgets/cabecalho_pagina.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/core/network/api_client.dart' show ApiException;
import 'package:tcc_mobile/shared/widgets/barra_navegacao.dart';
import 'package:tcc_mobile/shared/state/aparelhos_store.dart';
import 'package:tcc_mobile/features/analytics/presentation/graficos.dart';
import 'package:tcc_mobile/features/devices/data/dispositivos_api.dart';
import 'package:tcc_mobile/features/devices/data/samsung_ip_control_service.dart';
import 'package:tcc_mobile/features/devices/presentation/samsung_tv_discovery_dialog.dart';

class TelaDetalhesAparelho extends StatefulWidget {
  final String nome;
  final String id;
  final String backendId;
  final String tipo;
  final String fabricante;
  final String modelo;
  final String local;
  final String conexao;
  final String status;
  final IconData icone;

  const TelaDetalhesAparelho({
    super.key,
    this.nome = 'Ar condicionado',
    this.id = 'FH-AC-SALA-001',
    this.backendId = '',
    this.tipo = 'Ar condicionado',
    this.fabricante = 'Não informado',
    this.modelo = 'Não informado',
    this.local = 'Sala de Estar',
    this.conexao = 'Wi-Fi',
    this.status = 'Offline',
    this.icone = Icons.air,
  });

  /// Abre os detalhes/controles de um aparelho cadastrado.
  static Future<void> abrir(BuildContext context, AparelhoItem aparelho) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TelaDetalhesAparelho(
          nome: aparelho.nome,
          id: aparelho.id,
          backendId: aparelho.backendId,
          tipo: aparelho.tipo,
          fabricante: aparelho.fabricante,
          modelo: aparelho.modelo,
          local: aparelho.local,
          conexao: aparelho.conexao,
          status: aparelho.status,
          icone: aparelho.icone,
        ),
      ),
    );
  }

  @override
  State<TelaDetalhesAparelho> createState() => _TelaDetalhesAparelhoState();
}

class _TelaDetalhesAparelhoState extends State<TelaDetalhesAparelho> {
  static const Color marrom = AppColors.primary;
  static const Color amareloCard = AppColors.surface;
  static const Color amareloBotao = AppColors.surfaceStrong;

  bool ligado = false;
  bool modoSono = false;
  bool modoEconomico = false;
  bool mudo = false;
  bool privacidade = false;
  bool deteccaoMovimento = true;
  bool gravacao = false;
  bool temporizador = false;
  bool monitoramento = true;
  bool notificacoes = true;
  bool alerta = true;
  bool controleRemoto = false;

  double temperatura = 22;
  double volume = 35;
  double _volumeConfirmado = 35;
  double brilhoLampada = 76;
  double temperaturaCor = 50;

  int velocidadeVentilador = 2;
  int canalAtual = 0;
  String modoImagem = 'Padrão';

  bool _samsungCarregando = false;
  bool _samsungConectada = false;
  bool _samsungConfiguradaNoBackend = false;
  bool _estadoSamsungConhecido = false;
  String? _samsungIp;
  String? _samsungModelo;
  String? _samsungNome;
  String modoAr = 'Frio';
  String cenaLampada = 'Relaxar';
  final List<String> _presetsArPersonalizados = <String>[];
  final List<String> _cenasPersonalizadas = <String>[];
  final List<String> _servicosPersonalizados = <String>[];

  @override
  void initState() {
    super.initState();
    if (widget.tipo == 'TV' && widget.backendId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restaurarControleSamsung();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.main),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
                  child: _painelPrincipal(),
                ),
              ),
              const BarraNavegacao(itemSelecionado: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _painelPrincipal() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cabecalhoAparelho(),
              const SizedBox(height: 14),
              _conteudoPorTipo(),
              const SizedBox(height: 18),
              _rodapeIdentificacao(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalhoAparelho() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const BotaoVoltar(),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.tipo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: marrom.withValues(alpha: 0.72),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: amareloBotao,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.icone, color: marrom, size: 25),
        ),
        const SizedBox(width: 2),
        ValueListenableBuilder<Set<String>>(
          valueListenable: AparelhosStore.favoritos,
          builder: (context, favoritos, _) {
            final cadastrado = AparelhosStore.porId(widget.id) != null;
            final favorito = favoritos.contains(widget.id);
            return IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 36),
              tooltip: favorito
                  ? 'Remover dos favoritos'
                  : 'Adicionar aos favoritos',
              onPressed: () {
                if (!cadastrado) {
                  _mensagem(
                    'Cadastre este aparelho para adicioná-lo aos favoritos.',
                  );
                  return;
                }
                AparelhosStore.alternarFavorito(widget.id);
                _mensagem(
                  favorito
                      ? 'Removido dos favoritos.'
                      : 'Adicionado aos favoritos.',
                );
              },
              icon: Icon(
                favorito ? Icons.star_rounded : Icons.star_border_rounded,
                color: marrom,
                size: 23,
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          tooltip: 'Mais opções',
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.more_vert_rounded, color: marrom, size: 23),
          onSelected: (acao) {
            if (acao == 'informacoes') _mostrarInformacoes();
            if (acao == 'remover') _confirmarRemocao();
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              key: ValueKey<String>('menu-informacoes-aparelho'),
              value: 'informacoes',
              child: Text('Informações do aparelho'),
            ),
            if (AparelhosStore.porId(widget.id) != null)
              const PopupMenuItem<String>(
                value: 'remover',
                child: Text('Remover aparelho'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _restaurarControleSamsung() async {
    if (widget.backendId.isEmpty || !mounted) return;

    SamsungTvPairing? pareamento;
    try {
      pareamento = await SamsungIpControlService.carregarPareamento(
        widget.backendId,
      );
    } catch (error) {
      debugPrint('[FHIVE Samsung] Não foi possível ler o pareamento local: $error');
    }

    if (!mounted) return;
    setState(() {
      _samsungConectada = pareamento != null;
      _samsungIp = pareamento?.ip;
      _samsungNome = pareamento?.name;
      _samsungModelo = pareamento?.model;
      _estadoSamsungConhecido = false;
    });

    try {
      final configuracao = await DispositivosApi.controleLocal(widget.backendId);
      if (!mounted) return;
      setState(() {
        _samsungConfiguradaNoBackend = configuracao != null &&
            configuracao['provedor'] == 'samsung_ip_control';
        if (pareamento == null && configuracao != null) {
          _samsungIp = configuracao['ip']?.toString();
          _samsungNome = configuracao['nome']?.toString();
          _samsungModelo = configuracao['modelo']?.toString();
        }
      });
    } catch (error) {
      debugPrint('[FHIVE Samsung] Consulta do vínculo no backend falhou: $error');
    }

    // Se o token já existe no celular, tenta apenas sincronizar os metadados.
    // Nunca solicita outro token automaticamente durante a restauração.
    if (pareamento != null) {
      await _sincronizarVinculoSamsung(
        pareamento: pareamento,
        mostrarSucesso: false,
        mostrarErro: false,
      );
    }
  }

  Widget _cartaoConexaoSamsung() {
    final conectado = _samsungConectada && _samsungConfiguradaNoBackend;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: conectado ? AppColors.successSoft : amareloCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: conectado
              ? AppColors.success.withValues(alpha: 0.35)
              : marrom.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                conectado ? Icons.link_rounded : Icons.link_off_rounded,
                color: conectado ? AppColors.success : marrom,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  conectado ? 'Samsung conectada' : 'Conexão com a televisão',
                  style: AppTextStyles.bodyBold,
                ),
              ),
              if (_samsungCarregando)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (conectado)
                IconButton(
                  tooltip: 'Atualizar estado da TV',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _atualizarEstadoSamsung(),
                  icon: const Icon(Icons.refresh_rounded, color: marrom),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            conectado
                ? '${_samsungNome ?? 'Samsung Smart TV'} • ${_samsungIp ?? ''}\n${_samsungModelo ?? 'Modelo Samsung'}'
                : _samsungConectada && !_samsungConfiguradaNoBackend
                    ? 'A TV já autorizou este celular, mas o backend ainda não registrou o vínculo. Você pode tentar novamente sem pedir outra autorização à TV.'
                    : _samsungConfiguradaNoBackend
                        ? 'A TV está vinculada no FHIVE, mas este celular ainda precisa realizar o pareamento local.'
                        : 'Procure a TV Samsung na mesma rede Wi-Fi e autorize o FHIVE na televisão.',
            style: TextStyle(
              color: marrom.withValues(alpha: 0.78),
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_samsungConectada && !_samsungConfiguradaNoBackend)
                FilledButton.icon(
                  onPressed: _samsungCarregando
                      ? null
                      : () => _sincronizarVinculoSamsung(),
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  label: const Text('Tentar vínculo novamente'),
                )
              else
                FilledButton.icon(
                  onPressed: _samsungCarregando ? null : _conectarSamsung,
                  icon: Icon(
                    conectado ? Icons.refresh_rounded : Icons.wifi_find_rounded,
                    size: 18,
                  ),
                  label: Text(
                    conectado ? 'Parear outra TV' : 'Procurar TV Samsung',
                  ),
                ),
              if (_samsungConectada && !_samsungConfiguradaNoBackend)
                OutlinedButton.icon(
                  onPressed: _samsungCarregando ? null : _conectarSamsung,
                  icon: const Icon(Icons.tv_rounded, size: 17),
                  label: const Text('Escolher outra TV'),
                ),
              if (conectado)
                OutlinedButton.icon(
                  onPressed: _samsungCarregando ? null : _desconectarSamsung,
                  icon: const Icon(Icons.link_off_rounded, size: 17),
                  label: const Text('Desvincular'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _conectarSamsung() async {
    if (widget.backendId.isEmpty) {
      _mensagem('Este aparelho ainda não possui um registro no backend FHIVE.');
      return;
    }

    final tv = await showDialog<SamsungTvCandidate>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SamsungTvDiscoveryDialog(),
    );
    if (!mounted || tv == null) return;

    setState(() => _samsungCarregando = true);

    SamsungTvPairing pareamento;
    try {
      _mensagem('Solicitando autorização na TV. Confirme na tela da televisão.');
      pareamento = await SamsungIpControlService.parear(
        dispositivoBackendId: widget.backendId,
        tv: tv,
      );
    } on SamsungTvCommandException catch (error) {
      debugPrint('[FHIVE Samsung] Falha na etapa de autorização da TV: $error');
      if (mounted) {
        _mensagem('A TV não concluiu o pareamento: ${error.toString()}');
      }
      return;
    } catch (error, stackTrace) {
      debugPrint('[FHIVE Samsung] Erro inesperado no pareamento local: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        _mensagem('Falha ao parear diretamente com a TV: $error');
      }
      return;
    } finally {
      if (mounted) setState(() => _samsungCarregando = false);
    }

    // Neste ponto, a Samsung já autorizou o celular e o token já está salvo
    // no armazenamento seguro. A etapa seguinte é somente o vínculo no backend.
    if (!mounted) return;
    setState(() {
      _samsungConectada = true;
      _samsungConfiguradaNoBackend = false;
      _estadoSamsungConhecido = false;
      _samsungIp = pareamento.ip;
      _samsungNome = pareamento.name;
      _samsungModelo = pareamento.model;
    });

    await _sincronizarVinculoSamsung(
      pareamento: pareamento,
      mostrarSucesso: true,
    );
  }

  /// Registra/sincroniza somente os metadados no backend.
  /// Em caso de HTTP 400/500, o token local permanece salvo e este método
  /// pode ser repetido sem solicitar um novo token à televisão.
  Future<void> _sincronizarVinculoSamsung({
    SamsungTvPairing? pareamento,
    bool mostrarSucesso = true,
    bool mostrarErro = true,
  }) async {
    if (widget.backendId.isEmpty) {
      if (mostrarErro) _mensagem('O aparelho FHIVE não possui ID de backend.');
      return;
    }

    if (!mounted) return;
    var vinculadoComSucesso = false;
    setState(() => _samsungCarregando = true);
    try {
      final pairing = pareamento ??
          await SamsungIpControlService.carregarPareamento(widget.backendId);

      if (pairing == null) {
        throw const SamsungTvCommandException(
          mensagem: 'Não existe token Samsung salvo neste celular. Faça o pareamento com a TV primeiro.',
        );
      }

      await DispositivosApi.vincularControleLocal(
        dispositivoId: widget.backendId,
        provedor: 'samsung_ip_control',
        ip: pairing.ip,
        nome: pairing.name,
        modelo: pairing.model,
      );

      if (!mounted) return;
      setState(() {
        _samsungConectada = true;
        _samsungConfiguradaNoBackend = true;
        _samsungIp = pairing.ip;
        _samsungNome = pairing.name;
        _samsungModelo = pairing.model;
      });
      vinculadoComSucesso = true;

      if (mostrarSucesso) {
        _mensagem('TV Samsung pareada e vínculo FHIVE registrado com sucesso.');
      }
    } on ApiException catch (error) {
      debugPrint('[FHIVE Samsung] TV já pareada localmente; API FHIVE recusou o vínculo: $error');
      if (!mounted) return;
      setState(() => _samsungConfiguradaNoBackend = false);
      if (mostrarErro) {
        _mensagem(
          'O pareamento com a TV foi concluído e o token está salvo neste celular, mas o backend recusou o vínculo (${error.toString()}). Use “Tentar vínculo novamente”; não é necessário parear outra vez.',
        );
      }
    } on SamsungTvCommandException catch (error) {
      // O pareamento/vínculo já foi registrado; esta falha ocorre na consulta
      // posterior de estado da TV, não na gravação do vínculo.
      debugPrint('[FHIVE Samsung] Falha ao consultar a TV após o vínculo: $error');
      if (mounted && mostrarErro) {
        _mensagem('Vínculo salvo no FHIVE, mas não foi possível consultar o estado da TV: $error');
      }
    } catch (error, stackTrace) {
      debugPrint('[FHIVE Samsung] Falha ao sincronizar vínculo: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) setState(() => _samsungConfiguradaNoBackend = false);
      if (mounted && mostrarErro) {
        _mensagem('O token da TV foi preservado, mas o vínculo no backend falhou: $error');
      }
    } finally {
      if (mounted) setState(() => _samsungCarregando = false);
    }

    if (vinculadoComSucesso && mounted) {
      await _atualizarEstadoSamsung(silencioso: true);
    }
  }

  Future<void> _desconectarSamsung() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desvincular televisão?'),
        content: const Text(
          'O FHIVE removerá o token salvo neste celular e o vínculo de controle deste aparelho.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Desvincular'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;

    setState(() => _samsungCarregando = true);
    await SamsungIpControlService.removerPareamento(widget.backendId);
    if (mounted) {
      setState(() {
        _samsungConectada = false;
        _samsungConfiguradaNoBackend = false;
        _estadoSamsungConhecido = false;
        _samsungIp = null;
        _samsungNome = null;
        _samsungModelo = null;
      });
    }

    try {
      await DispositivosApi.desvincularControleLocal(widget.backendId);
      if (mounted) _mensagem('Controle Samsung desvinculado.');
    } catch (error) {
      if (mounted) {
        _mensagem(
          'O token foi removido deste celular, mas o backend não confirmou a remoção do vínculo: ${error.toString()}',
        );
      }
    } finally {
      if (mounted) setState(() => _samsungCarregando = false);
    }
  }

  Future<void> _atualizarEstadoSamsung({bool silencioso = false}) async {
    if (!_samsungConectada || !_samsungConfiguradaNoBackend || _samsungCarregando) return;
    setState(() => _samsungCarregando = true);
    try {
      final resposta = await SamsungIpControlService.consultarEstado(widget.backendId);
      final tv = resposta['tv'] is Map
          ? Map<String, dynamic>.from(resposta['tv'] as Map)
          : <String, dynamic>{};
      final energia = resposta['energia'] is Map
          ? Map<String, dynamic>.from(resposta['energia'] as Map)
          : <String, dynamic>{};

      final volumeLido = double.tryParse('${tv['volume'] ?? ''}');
      final muteValor = '${tv['mute'] ?? ''}'.toLowerCase();
      final powerValor = '${energia['power'] ?? ''}'.toLowerCase();
      final canalLido = int.tryParse('${tv['channelNum'] ?? tv['channel'] ?? ''}');

      if (!mounted) return;
      setState(() {
        if (volumeLido != null) {
          volume = volumeLido.clamp(0, 100).toDouble();
          _volumeConfirmado = volume;
        }
        if (muteValor.isNotEmpty) {
          mudo = muteValor == 'muteon' || muteValor == 'true' || muteValor == 'on';
        }
        if (powerValor.isNotEmpty) {
          ligado = powerValor == 'poweron' || powerValor == 'on';
          _estadoSamsungConhecido = true;
        }
        if (canalLido != null) canalAtual = canalLido;
      });
      if (!silencioso) _mensagem('Estado da televisão atualizado.');
    } catch (error) {
      if (!silencioso && mounted) {
        _mensagem('Não foi possível consultar a TV: ${error.toString()}');
      }
    } finally {
      if (mounted) setState(() => _samsungCarregando = false);
    }
  }

  Future<bool> _executarComandoSamsung(
    Future<void> Function() executar, {
    required String sucesso,
  }) async {
    if (!_samsungConectada) {
      _mensagem('Conecte e autorize uma TV Samsung antes de enviar comandos.');
      return false;
    }
    if (!_samsungConfiguradaNoBackend) {
      _mensagem('O backend ainda não confirmou o vínculo deste aparelho. Verifique sua conexão com o FHIVE e tente parear novamente.');
      return false;
    }
    if (_samsungCarregando) return false;

    setState(() => _samsungCarregando = true);
    try {
      await executar();
      if (mounted) _mensagem(sucesso);
      return true;
    } on SamsungTvCommandException catch (error) {
      if (!mounted) return false;
      final codigo = error.codigo;
      if (codigo == '-32601' || codigo == '-32602' || codigo == '-32003') {
        _mensagem('A sua TV não oferece suporte a esse comando ou parâmetro. ${error.mensagem}');
      } else if (codigo == '-32010') {
        setState(() => _samsungConectada = false);
        _mensagem('A autorização da TV expirou ou foi substituída. Faça o pareamento novamente.');
      } else {
        _mensagem(error.mensagem);
      }
      return false;
    } catch (error) {
      if (mounted) _mensagem('Falha ao enviar comando: ${error.toString()}');
      return false;
    } finally {
      if (mounted) setState(() => _samsungCarregando = false);
    }
  }

  Future<void> _alternarEnergiaSamsung() => _definirEnergiaSamsung(!ligado);

  Future<void> _definirEnergiaSamsung(bool novoEstado) async {
    await _executarComandoSamsung(
      () async {
        await SamsungIpControlService.definirEnergia(
          widget.backendId,
          ligado: novoEstado,
        );
        if (mounted) setState(() => ligado = novoEstado);
      },
      sucesso: novoEstado ? 'Comando para ligar enviado à TV.' : 'Comando para desligar enviado à TV.',
    );
  }

  Future<void> _enviarVolumeSamsung(double valor) async {
    final enviado = await _executarComandoSamsung(
      () async {
        await SamsungIpControlService.definirVolume(
          widget.backendId,
          volume: valor.round(),
        );
        if (mounted) {
          setState(() {
            volume = valor;
            _volumeConfirmado = valor;
          });
        }
      },
      sucesso: 'Volume atualizado para ${valor.round()}%.',
    );

    if (!enviado && mounted) {
      setState(() => volume = _volumeConfirmado);
    }
  }

  Future<void> _alterarVolumeRelativoSamsung(bool aumentar) async {
    await _executarComandoSamsung(
      () async {
        await SamsungIpControlService.alterarVolumeRelativo(
          widget.backendId,
          aumentar: aumentar,
        );
        if (mounted) {
          setState(() {
            volume = (volume + (aumentar ? 1 : -1)).clamp(0, 100).toDouble();
            _volumeConfirmado = volume;
          });
        }
      },
      sucesso: aumentar ? 'Volume aumentado.' : 'Volume diminuído.',
    );
  }

  Future<void> _definirSilencioSamsung(bool novoEstado) async {
    await _executarComandoSamsung(
      () async {
        await SamsungIpControlService.definirSilencio(
          widget.backendId,
          silenciado: novoEstado,
        );
        if (mounted) setState(() => mudo = novoEstado);
      },
      sucesso: novoEstado ? 'Televisão silenciada.' : 'Som da televisão ativado.',
    );
  }

  Future<void> _trocarCanalSamsung({required bool avancar}) async {
    await _executarComandoSamsung(
      () async {
        await SamsungIpControlService.trocarCanal(
          widget.backendId,
          avancar: avancar,
        );
        if (mounted && canalAtual > 0) {
          setState(() => canalAtual = (canalAtual + (avancar ? 1 : -1)).clamp(0, 999));
        }
      },
      sucesso: avancar ? 'Comando para avançar um canal enviado.' : 'Comando para voltar um canal enviado.',
    );
  }

  Future<void> _abrirAplicativoSamsung(String nome) async {
    const aplicativos = <String, String>{
      'YouTube': 'youTube',
      'Netflix': 'netflix',
      'Prime': 'amazon',
    };
    final applicationName = aplicativos[nome];
    if (applicationName == null) {
      _mensagem('O aplicativo $nome ainda não foi validado nesta TV. Nenhum comando foi enviado.');
      return;
    }

    await _executarComandoSamsung(
      () => SamsungIpControlService.abrirAplicativo(
        widget.backendId,
        applicationName: applicationName,
      ),
      sucesso: 'Solicitação para abrir $nome enviada. Confira a tela da TV.',
    );
  }

  Future<void> _alterarModoImagemSamsung(String modo) async {
    await _executarComandoSamsung(
      () async {
        await SamsungIpControlService.definirModoImagem(
          widget.backendId,
          modo: modo,
        );
        if (mounted) setState(() => modoImagem = modo);
      },
      sucesso: 'Modo de imagem $modo aplicado.',
    );
  }

  Widget _conteudoPorTipo() {
    switch (widget.tipo) {
      case 'TV':
        return _conteudoTV();
      case 'Ar condicionado':
        return _conteudoAr();
      case 'Lâmpada':
        return _conteudoLampada();
      case 'Câmera':
        return _conteudoCamera();
      case 'Tomada inteligente':
        return _conteudoTomada();
      case 'Sensor':
        return _conteudoSensor();
      default:
        return _conteudoGenerico();
    }
  }

  Widget _conteudoTV() {
    final estadoConhecido = _samsungConectada && _estadoSamsungConhecido;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.surfaceStrong],
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: marrom.withValues(alpha: 0.09)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: const Icon(Icons.tv_rounded, color: marrom, size: 35),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.local,
                          style: TextStyle(
                            color: marrom.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: estadoConhecido && ligado
                                ? AppColors.successSoft
                                : AppColors.surfaceLight.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                estadoConhecido && ligado
                                    ? Icons.check_circle
                                    : Icons.power_settings_new,
                                size: 13,
                                color: estadoConhecido && ligado
                                    ? AppColors.success
                                    : marrom,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                !estadoConhecido
                                    ? 'Estado não consultado'
                                    : ligado
                                        ? 'Ligada'
                                        : 'Desligada',
                                style: const TextStyle(
                                  color: marrom,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Material(
                    color: marrom,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: ligado ? 'Desligar TV' : 'Ligar TV',
                      onPressed: _samsungCarregando ? null : _alternarEnergiaSamsung,
                      icon: Icon(
                        ligado ? Icons.power_settings_new_rounded : Icons.power_settings_new,
                        color: AppColors.white,
                        size: 29,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _samsungCarregando ? null : _alternarEnergiaSamsung,
                  icon: Icon(ligado ? Icons.power_off_rounded : Icons.power_rounded),
                  label: Text(ligado ? 'Desligar TV' : 'Ligar TV'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _cartaoConexaoSamsung(),
        const SizedBox(height: 18),
        const Text(
          'Controles rápidos',
          style: AppTextStyles.cardTitle,
        ),
        const SizedBox(height: 8),
        _linhaSlider(
          titulo: 'Volume',
          valor: volume,
          min: 0,
          max: 100,
          textoValor: '${volume.round()}%',
          iconeFinal: Icons.volume_up_rounded,
          onChanged: (valor) => setState(() => volume = valor),
          onChangeEnd: (valor) => _enviarVolumeSamsung(valor),
          enabled: _samsungConectada && _samsungConfiguradaNoBackend && !_samsungCarregando,
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: amareloCard,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Row(
            children: [
              const Icon(Icons.live_tv_rounded, color: marrom, size: 23),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Canal',
                  style: AppTextStyles.bodyBold,
                ),
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: !_samsungConectada || !_samsungConfiguradaNoBackend || _samsungCarregando ? null : () => _trocarCanalSamsung(avancar: false),
                icon: const Icon(Icons.remove_rounded),
                style: IconButton.styleFrom(foregroundColor: marrom, backgroundColor: AppColors.surfaceLight),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Text(canalAtual > 0 ? '$canalAtual' : '—', style: AppTextStyles.cardTitle),
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: !_samsungConectada || !_samsungConfiguradaNoBackend || _samsungCarregando ? null : () => _trocarCanalSamsung(avancar: true),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(foregroundColor: marrom, backgroundColor: AppColors.surfaceLight),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _linhaSwitch(
          'Desligamento automático',
          temporizador,
          Icons.timer_outlined,
          (valor) => _mensagem(
            'O temporizador ainda não foi validado para esta TV. Nenhuma alteração foi enviada.',
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Modo de imagem',
          style: AppTextStyles.bodyBold,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: ['Padrão', 'Cinema', 'Jogo'].map((modo) {
            final selecionado = modoImagem == modo;
            return ChoiceChip(
              avatar: Icon(
                modo == 'Cinema' ? Icons.movie_outlined : modo == 'Jogo' ? Icons.sports_esports_outlined : Icons.tune_rounded,
                size: 17,
                color: marrom,
              ),
              label: Text(modo),
              selected: selecionado,
              onSelected: _samsungConectada && _samsungConfiguradaNoBackend && !_samsungCarregando
                  ? (_) => _alterarModoImagemSamsung(modo)
                  : null,
              selectedColor: amareloBotao,
              backgroundColor: amareloCard,
              labelStyle: const TextStyle(color: marrom, fontWeight: FontWeight.w800, fontSize: 12),
              side: BorderSide(color: marrom.withValues(alpha: 0.12)),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _painelAtalhosEStreamingTV(),
        const SizedBox(height: 14),
        _linkTitulo('Ver gráficos deste aparelho', _abrirGraficos),
      ],
    );
  }

  Widget _painelAtalhosEStreamingTV() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: amareloCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: marrom.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _atalhosRapidosTV(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: marrom.withValues(alpha: 0.12),
            ),
          ),
          const Text(
            'Aplicativos de streaming',
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: 10),
          _streamingGrid(),
          const SizedBox(height: 8),
          Text(
            'Os comandos compatíveis são enviados diretamente à TV pela rede Wi-Fi. Aplicativos não validados são bloqueados com uma mensagem.',
            style: TextStyle(
              color: marrom.withValues(alpha: 0.7),
              fontSize: 10,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _atalhosRapidosTV() {
    const comandos = <String, IconData>{
      'Ligar TV': Icons.power_settings_new_rounded,
      'Desligar TV': Icons.power_off_rounded,
      'Aumentar volume': Icons.volume_up_rounded,
      'Diminuir volume': Icons.volume_down_rounded,
      'Silenciar': Icons.volume_off_rounded,
      'Canal +': Icons.add_circle_outline_rounded,
      'Canal -': Icons.remove_circle_outline_rounded,
      'Modo Cinema': Icons.movie_outlined,
      'Modo Jogo': Icons.sports_esports_outlined,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Atalhos rápidos',
                style: AppTextStyles.cardTitle,
              ),
            ),
            TextButton.icon(
              onPressed: _adicionarAtalhoTV,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Adicionar'),
              style: TextButton.styleFrom(foregroundColor: marrom),
            ),
          ],
        ),
        ValueListenableBuilder<List<AtalhoAparelho>>(
          valueListenable: AparelhosStore.atalhos,
          builder: (context, todosAtalhos, _) {
            final atalhos = todosAtalhos.where((item) => item.aparelhoId == widget.id).toList();
            if (atalhos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: marrom, size: 25),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Crie um atalho para executar seus comandos favoritos em um toque.',
                        style: TextStyle(
                          color: marrom,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: atalhos.map((atalho) {
                return SizedBox(
                  width: (MediaQuery.sizeOf(context).width - 84) / 2,
                  child: Material(
                    color: amareloCard,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                      onTap: () => _executarAtalhoTV(atalho.comando),
                      onLongPress: () => _removerAtalhoTV(atalho.id),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(11, 10, 7, 10),
                        child: Row(
                          children: [
                            Icon(comandos[atalho.comando] ?? atalho.icone, color: marrom, size: 22),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                atalho.nome,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _adicionarAtalhoTV() async {
    final dados = await showDialog<(String, String)?>(
      context: context,
      builder: (_) => const _DialogoAtalhoTV(),
    );
    if (!mounted || dados == null) return;
    if (dados.$1.isEmpty) {
      _mensagem('Informe um nome para o atalho.');
      return;
    }
    final adicionado = AparelhosStore.adicionarAtalho(
      aparelhoId: widget.id,
      nome: dados.$1,
      comando: dados.$2,
      icone: _comandosAtalhoTV[dados.$2] ?? Icons.bolt_rounded,
    );
    if (!adicionado) {
      _mensagem('Já existe um atalho com esse nome ou o aparelho não está cadastrado.');
      return;
    }
    _mensagem('Atalho "${dados.$1}" adicionado. Toque nele para executar; mantenha pressionado para remover.');
  }

  Future<void> _executarAtalhoTV(String comando) async {
    switch (comando) {
      case 'Ligar TV':
        await _definirEnergiaSamsung(true);
        break;
      case 'Desligar TV':
        await _definirEnergiaSamsung(false);
        break;
      case 'Aumentar volume':
        await _alterarVolumeRelativoSamsung(true);
        break;
      case 'Diminuir volume':
        await _alterarVolumeRelativoSamsung(false);
        break;
      case 'Silenciar':
        await _definirSilencioSamsung(!mudo);
        break;
      case 'Canal +':
        await _trocarCanalSamsung(avancar: true);
        break;
      case 'Canal -':
        await _trocarCanalSamsung(avancar: false);
        break;
      case 'Modo Cinema':
        await _alterarModoImagemSamsung('Cinema');
        break;
      case 'Modo Jogo':
        await _alterarModoImagemSamsung('Jogo');
        break;
      default:
        _mensagem('Esse atalho não possui um comando físico configurado.');
    }
  }

  Future<void> _removerAtalhoTV(String id) async {
    final remover = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover atalho?'),
        content: const Text('Esse atalho será removido da lista deste aparelho.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Remover')),
        ],
      ),
    );
    if (!mounted || remover != true) return;
    AparelhosStore.removerAtalho(id);
    _mensagem('Atalho removido.');
  }

  Widget _conteudoAr() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch(
          'Ligar/Desligar',
          ligado,
          Icons.power_settings_new,
          (valor) => setState(() => ligado = valor),
        ),
        _linhaSlider(
          titulo: 'Temperatura',
          valor: temperatura,
          min: 16,
          max: 30,
          textoValor: '${temperatura.round()}°C',
          iconeFinal: Icons.thermostat_auto_outlined,
          onChanged: (valor) => setState(() => temperatura = valor),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: _botaoOpcao(
                icon: Icons.power_settings_new_rounded,
                label: 'Desligamento\nAutomático',
                ativo: temporizador,
                onTap: () => setState(() => temporizador = !temporizador),
              ),
            ),
            const SizedBox(width: 50),
            Expanded(
              child: _botaoOpcao(
                icon: Icons.speed_rounded,
                label: 'Velocidade do\nventilador',
                onTap: () => setState(
                  () => velocidadeVentilador = velocidadeVentilador == 4
                      ? 1
                      : velocidadeVentilador + 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _botaoOpcao(
                icon: Icons.air_rounded,
                label: 'Modo\nEconômico',
                ativo: modoEconomico,
                onTap: () => setState(() => modoEconomico = !modoEconomico),
              ),
            ),
            const SizedBox(width: 50),
            Expanded(
              child: _botaoOpcao(
                icon: Icons.nightlight_round,
                label: 'Modo sono',
                ativo: modoSono,
                onTap: () => setState(() => modoSono = !modoSono),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _linkTitulo('Gráficos', _abrirGraficos),
        const SizedBox(height: 13),
        const Text(
          'Pré-configurações',
          style: AppTextStyles.cardTitle,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _preset('Frio', modoAr == 'Frio'),
            _preset('Calor', modoAr == 'Calor'),
            for (final preset in _presetsArPersonalizados)
              _preset(preset, modoAr == preset),
            _preset('+', false, icon: Icons.add, largura: 68),
          ],
        ),
      ],
    );
  }

  Widget _conteudoLampada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch(
          'Ligar/Desligar',
          ligado,
          Icons.power_settings_new,
          (valor) => setState(() => ligado = valor),
        ),
        _linhaSlider(
          titulo: 'Brilho',
          valor: brilhoLampada,
          min: 1,
          max: 100,
          textoValor: '${brilhoLampada.round()}%',
          iconeFinal: Icons.light_mode_outlined,
          onChanged: (valor) => setState(() => brilhoLampada = valor),
        ),
        _linhaSlider(
          titulo: 'Temperatura da cor',
          valor: temperaturaCor,
          min: 0,
          max: 100,
          textoValor: temperaturaCor < 45
              ? 'Quente'
              : temperaturaCor > 65
              ? 'Fria'
              : 'Neutra',
          iconeFinal: Icons.palette_outlined,
          onChanged: (valor) => setState(() => temperaturaCor = valor),
        ),
        _linkTitulo('Cenas', _abrirCenas),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final cena in <String>[
              'Relaxar',
              'Leitura',
              'Filme',
              ..._cenasPersonalizadas,
            ])
              _preset(cena, cena == cenaLampada),
            _preset('+', false, icon: Icons.add, largura: 68),
          ],
        ),
      ],
    );
  }

  Widget _conteudoCamera() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoBanner(
          Icons.videocam_outlined,
          'Visualização disponível quando a integração de vídeo estiver ativa.',
        ),
        const SizedBox(height: 14),
        _linhaSwitch(
          'Privacidade',
          privacidade,
          Icons.visibility_off_outlined,
          (valor) => setState(() => privacidade = valor),
        ),
        _linhaSwitch(
          'Detecção de movimento',
          deteccaoMovimento,
          Icons.directions_run_rounded,
          (valor) => setState(() => deteccaoMovimento = valor),
        ),
        _linhaSwitch(
          'Gravação',
          gravacao,
          Icons.fiber_manual_record_outlined,
          (valor) => setState(() => gravacao = valor),
        ),
        _linkTitulo('Gráficos', _abrirGraficos),
      ],
    );
  }

  Widget _conteudoTomada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch(
          'Ligar/Desligar',
          ligado,
          Icons.power_settings_new,
          (valor) => setState(() => ligado = valor),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _indicador('Potência', '184 W', Icons.bolt_outlined),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _indicador('Hoje', '1,8 kWh', Icons.bar_chart_outlined),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _linhaSwitch(
          'Temporizador',
          temporizador,
          Icons.timer_outlined,
          (valor) => setState(() => temporizador = valor),
        ),
        _linhaSwitch(
          'Economia de energia',
          modoEconomico,
          Icons.eco_outlined,
          (valor) => setState(() => modoEconomico = valor),
        ),
      ],
    );
  }

  Widget _conteudoSensor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _indicador(
                'Temperatura',
                '23°C',
                Icons.thermostat_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _indicador('Umidade', '58%', Icons.water_drop_outlined),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _linhaSwitch(
          'Monitoramento ativo',
          monitoramento,
          Icons.sensors_outlined,
          (valor) => setState(() => monitoramento = valor),
        ),
        _linhaSwitch(
          'Notificar alterações',
          notificacoes,
          Icons.notifications_none_outlined,
          (valor) => setState(() => notificacoes = valor),
        ),
        _linhaSwitch(
          'Alertas de limite',
          alerta,
          Icons.warning_amber_outlined,
          (valor) => setState(() => alerta = valor),
        ),
      ],
    );
  }

  Widget _conteudoGenerico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _linhaSwitch(
          'Ligar/Desligar',
          ligado,
          Icons.power_settings_new,
          (valor) => setState(() => ligado = valor),
        ),
        _linhaSwitch(
          'Notificações',
          notificacoes,
          Icons.notifications_none_outlined,
          (valor) => setState(() => notificacoes = valor),
        ),
        _linkTitulo('Gráficos', _abrirGraficos),
      ],
    );
  }

  Widget _linhaSwitch(
    String titulo,
    bool valor,
    IconData icone,
    ValueChanged<bool> onChanged,
  ) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: AppTextStyles.bodyBold,
            ),
          ),
          Switch.adaptive(
            value: valor,
            onChanged: onChanged,
            activeThumbColor: marrom,
            activeTrackColor: amareloBotao,
            inactiveThumbColor: marrom,
            inactiveTrackColor: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  Widget _linhaSlider({
    required String titulo,
    required double valor,
    required double min,
    required double max,
    required String textoValor,
    required IconData iconeFinal,
    required ValueChanged<double> onChanged,
    ValueChanged<double>? onChangeEnd,
    bool enabled = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            titulo,
            style: AppTextStyles.bodyBold,
          ),
        ),
        Expanded(
          flex: 4,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              activeTrackColor: marrom,
              inactiveTrackColor: marrom.withValues(alpha: 0.18),
              thumbColor: marrom,
              overlayColor: marrom.withValues(alpha: 0.10),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              min: min,
              max: max,
              value: valor.clamp(min, max).toDouble(),
              onChanged: enabled ? onChanged : null,
              onChangeEnd: enabled ? onChangeEnd : null,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            textoValor,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyBold,
          ),
        ),
        const SizedBox(width: 5),
        Icon(iconeFinal, color: marrom, size: 21),
      ],
    );
  }

  Widget _botaoOpcao({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool ativo = false,
  }) {
    return Material(
      color: ativo ? amareloBotao : amareloCard,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: SizedBox(
          height: 82,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: marrom, size: 37),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: marrom,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preset(
    String texto,
    bool ativo, {
    IconData? icon,
    double largura = 68,
  }) {
    return Material(
      color: ativo ? amareloBotao : amareloCard,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          if (texto == '+') {
            _adicionarPreConfiguracao();
            return;
          }
          if (widget.tipo == 'Ar condicionado') {
            setState(() => modoAr = texto);
          } else if (widget.tipo == 'Lâmpada') {
            setState(() => cenaLampada = texto);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: largura,
          height: 68,
          child: Center(
            child: icon != null
                ? Icon(icon, color: marrom, size: 36)
                : Text(
                    texto,
                    style: const TextStyle(
                      color: marrom,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _linkTitulo(String texto, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(color: marrom.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    color: marrom,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                color: marrom.withValues(alpha: 0.78),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _streamingGrid() {
    final itens = <(String, Color, IconData)>[
      ('Twitch', const Color(0xFF9146FF), Icons.chat_bubble_outline_rounded),
      ('Disney+', const Color(0xFF071A5B), Icons.movie_creation_outlined),
      ('Prime', const Color(0xFF20A6F5), Icons.play_arrow_rounded),
      ('YouTube', const Color(0xFFFF1F19), Icons.play_arrow_rounded),
      ('Netflix', Colors.black, Icons.movie_outlined),
      for (final nome in _servicosPersonalizados)
        (nome, marrom, Icons.apps_outlined),
      ('+', amareloBotao, Icons.add),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: itens.map((item) {
        final ehAdicionar = item.$1 == '+';
        return Material(
          color: item.$2,
          borderRadius: BorderRadius.circular(7),
          child: InkWell(
            onTap: () {
              if (ehAdicionar) {
                _adicionarServicoStreaming();
              } else {
                _abrirAplicativoSamsung(item.$1);
              }
            },
            borderRadius: BorderRadius.circular(7),
            child: SizedBox(
              width: 55,
              height: 55,
              child: Center(
                child: Icon(
                  item.$3,
                  color: ehAdicionar ? marrom : AppColors.white,
                  size: ehAdicionar ? 31 : 27,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _infoBanner(IconData icon, String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: amareloCard,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          Icon(icon, color: marrom, size: 26),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: marrom,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicador(String titulo, String valor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: amareloCard,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        children: [
          Icon(icon, color: marrom, size: 22),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: marrom.withValues(alpha: 0.70),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: AppTextStyles.bodyBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rodapeIdentificacao() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      iconColor: marrom,
      collapsedIconColor: marrom,
      title: const Text(
        'Informações do aparelho',
        style: AppTextStyles.bodyBold,
      ),
      children: [
        _linhaInfo('ID', widget.id),
        _linhaInfo('Fabricante', widget.fabricante),
        _linhaInfo('Modelo', widget.modelo),
        _linhaInfo('Conexão', widget.conexao),
        _linhaInfo('Local', widget.local),
        _linhaInfo('Status', widget.status),
      ],
    );
  }

  Widget _linhaInfo(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: marrom, fontSize: 12, height: 1.25),
          children: [
            TextSpan(
              text: '$titulo: ',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }

  Future<void> _adicionarPreConfiguracao() async {
    final nome = await pedirTexto(
      context,
      titulo: 'Nova pré-configuração',
      rotulo: 'Nome',
    );
    if (!mounted || nome == null) return;
    final limpo = nome.trim();
    if (limpo.isEmpty) {
      _mensagem('Informe um nome para a pré-configuração.');
      return;
    }
    final listaExistente = widget.tipo == 'Ar condicionado'
        ? _presetsArPersonalizados
        : _cenasPersonalizadas;
    final nomeDuplicado = listaExistente.any(
      (item) => item.toLowerCase() == limpo.toLowerCase(),
    );
    if (nomeDuplicado) {
      _mensagem('Essa pré-configuração já existe.');
      return;
    }

    setState(() {
      if (widget.tipo == 'Ar condicionado') {
        _presetsArPersonalizados.add(limpo);
        modoAr = limpo;
      } else if (widget.tipo == 'Lâmpada') {
        _cenasPersonalizadas.add(limpo);
        cenaLampada = limpo;
      }
    });
  }

  Future<void> _adicionarServicoStreaming() async {
    final nome = await pedirTexto(
      context,
      titulo: 'Adicionar streaming',
      rotulo: 'Nome do serviço',
    );
    if (!mounted || nome == null) return;
    final limpo = nome.trim();
    if (limpo.isEmpty) {
      _mensagem('Digite o nome do serviço.');
      return;
    }
    if (<String>[
      'Twitch',
      'Disney+',
      'Prime',
      'YouTube',
      'Netflix',
      ..._servicosPersonalizados,
    ].any((item) => item.toLowerCase() == limpo.toLowerCase())) {
      _mensagem('Esse serviço já está na lista.');
      return;
    }
    setState(() => _servicosPersonalizados.add(limpo));
  }

  void _abrirCenas() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: amareloCard,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cenas da iluminação',
                style: TextStyle(
                  color: marrom,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              for (final cena in <String>[
                'Relaxar',
                'Leitura',
                'Filme',
                ..._cenasPersonalizadas,
              ])
                ListTile(
                  title: Text(cena, style: const TextStyle(color: marrom)),
                  trailing: cenaLampada == cena
                      ? const Icon(Icons.check, color: marrom)
                      : null,
                  onTap: () {
                    setState(() => cenaLampada = cena);
                    Navigator.pop(sheetContext);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.add, color: marrom),
                title: const Text(
                  'Criar cena',
                  style: TextStyle(color: marrom),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _adicionarPreConfiguracao();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirGraficos() {
    if (widget.tipo != 'TV' && widget.tipo != 'Ar condicionado') {
      Navigator.pushNamed(context, '/graficos');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaGraficosDetalhes(
          tipo: widget.tipo == 'TV'
              ? TipoAparelho.tv
              : TipoAparelho.arCondicionado,
          nomePersonalizado: widget.nome,
          local: widget.local,
          status: widget.status,
          deviceBackendId: widget.backendId,
          aparelhoSelecionado: AparelhoItem(
            nome: widget.nome,
            id: widget.id,
            backendId: widget.backendId,
            tipo: widget.tipo,
            fabricante: widget.fabricante,
            modelo: widget.modelo,
            status: widget.status,
            icone: widget.icone,
            wifi: widget.conexao.toLowerCase().contains('wi-fi'),
            local: widget.local,
            conexao: widget.conexao,
          ),
        ),
      ),
    );
  }

  void _mostrarInformacoes() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Informações do aparelho'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _linhaInfo('Nome', widget.nome),
              _linhaInfo('Tipo', widget.tipo),
              _linhaInfo('ID', widget.id),
              _linhaInfo('Fabricante', widget.fabricante),
              _linhaInfo('Modelo', widget.modelo),
              _linhaInfo('Conexão', widget.conexao),
              _linhaInfo('Local', widget.local),
              _linhaInfo('Status', widget.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarRemocao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover aparelho'),
        content: Text('Deseja remover "${widget.nome}" da lista da casa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    try {
      await AparelhosStore.removerDoBackend(widget.id);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) _mensagem(error.toString());
    }
  }

  void _mensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }
}

const Map<String, IconData> _comandosAtalhoTV = <String, IconData>{
  'Ligar TV': Icons.power_settings_new_rounded,
  'Desligar TV': Icons.power_off_rounded,
  'Aumentar volume': Icons.volume_up_rounded,
  'Diminuir volume': Icons.volume_down_rounded,
  'Silenciar': Icons.volume_off_rounded,
  'Canal +': Icons.add_circle_outline_rounded,
  'Canal -': Icons.remove_circle_outline_rounded,
  'Modo Cinema': Icons.movie_outlined,
  'Modo Jogo': Icons.sports_esports_outlined,
};

class _DialogoAtalhoTV extends StatefulWidget {
  const _DialogoAtalhoTV();

  @override
  State<_DialogoAtalhoTV> createState() => _DialogoAtalhoTVState();
}

class _DialogoAtalhoTVState extends State<_DialogoAtalhoTV> {
  final TextEditingController _nome = TextEditingController();
  String _comando = 'Ligar TV';

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar atalho'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nome,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome do atalho',
              hintText: 'Ex.: Noite de cinema',
              prefixIcon: Icon(Icons.bolt_rounded),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _comando,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Comando'),
            items: _comandosAtalhoTV.keys
                .map((c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (valor) {
              if (valor != null) setState(() => _comando = valor);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((_nome.text.trim(), _comando)),
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

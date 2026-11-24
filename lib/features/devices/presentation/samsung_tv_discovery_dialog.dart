import 'package:flutter/material.dart';
import 'package:tcc_mobile/core/theme/theme.dart';
import 'package:tcc_mobile/features/devices/data/samsung_ip_control_service.dart';

/// Permite descobrir uma Samsung TV pela rede atual ou validar um IP informado.
class SamsungTvDiscoveryDialog extends StatefulWidget {
  const SamsungTvDiscoveryDialog({super.key});

  @override
  State<SamsungTvDiscoveryDialog> createState() =>
      _SamsungTvDiscoveryDialogState();
}

class _SamsungTvDiscoveryDialogState extends State<SamsungTvDiscoveryDialog> {
  final TextEditingController _ipController = TextEditingController();
  final List<SamsungTvCandidate> _encontradas = <SamsungTvCandidate>[];

  SamsungTvCandidate? _selecionada;
  bool _buscando = false;
  bool _validandoIp = false;
  String? _erro;
  String? _aviso;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _buscarNaRede() async {
    if (_buscando) return;
    setState(() {
      _buscando = true;
      _erro = null;
      _aviso = 'Verificando a rede Wi-Fi atual. Isso pode levar alguns segundos.';
      _encontradas.clear();
      _selecionada = null;
    });

    try {
      final resultado = await SamsungIpControlService.descobrirNaRede();
      if (!mounted) return;
      setState(() {
        _encontradas
          ..clear()
          ..addAll(resultado);
        if (_encontradas.length == 1) {
          _selecionada = _encontradas.first;
          _ipController.text = _selecionada!.ip;
        }
        _aviso = resultado.isEmpty
            ? 'Nenhuma TV Samsung compatível foi encontrada automaticamente. Você também pode informar o IP manualmente.'
            : '${resultado.length} TV(s) Samsung encontrada(s). Selecione uma para continuar.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _erro = error.toString();
        _aviso = null;
      });
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _validarIpInformado() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty || _validandoIp) {
      setState(() => _erro = 'Informe o endereço IP da televisão.');
      return;
    }

    setState(() {
      _validandoIp = true;
      _erro = null;
      _aviso = 'Validando a TV e a porta Samsung IP Control...';
    });

    try {
      final tv = await SamsungIpControlService.verificarIp(ip);
      if (!mounted) return;
      setState(() {
        _selecionada = tv;
        if (!_encontradas.any((item) => item.ip == tv.ip)) {
          _encontradas.add(tv);
        }
        _aviso = 'TV Samsung identificada e compatível com a porta IP Control.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _erro = error.toString();
        _aviso = null;
        _selecionada = null;
      });
    } finally {
      if (mounted) setState(() => _validandoIp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Conectar TV Samsung'),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.82,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O celular precisa estar conectado ao mesmo Wi-Fi da TV. O FHIVE procura televisões compatíveis na rede ou valida um IP informado.',
                style: TextStyle(fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _buscando || _validandoIp ? null : _buscarNaRede,
                  icon: _buscando
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_find_rounded),
                  label: Text(_buscando ? 'Procurando na rede...' : 'Buscar TVs na rede Wi-Fi'),
                ),
              ),
              if (_encontradas.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'TVs encontradas',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                ..._encontradas.map((tv) {
                  final selecionada = _selecionada?.ip == tv.ip;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Material(
                      color: selecionada
                          ? AppColors.surfaceStrong
                          : AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: selecionada
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.tv_rounded, color: AppColors.primary),
                        title: Text(tv.name.isEmpty ? 'Samsung Smart TV' : tv.name),
                        subtitle: Text('${tv.model} • ${tv.ip}'),
                        trailing: selecionada
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
                        onTap: () {
                          setState(() {
                            _selecionada = tv;
                            _ipController.text = tv.ip;
                            _erro = null;
                          });
                        },
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 14),
              const Text(
                'Ou informe o IP manualmente',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: _ipController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Endereço IP da TV',
                  hintText: 'Ex.: 192.168.1.100',
                  prefixIcon: Icon(Icons.lan_outlined),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {
                  _selecionada = null;
                  _erro = null;
                }),
              ),
              const SizedBox(height: 7),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _buscando || _validandoIp ? null : _validarIpInformado,
                  icon: _validandoIp
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(_validandoIp ? 'Validando...' : 'Validar IP'),
                ),
              ),
              if (_aviso != null) ...[
                const SizedBox(height: 4),
                Text(
                  _aviso!,
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
              if (_erro != null) ...[
                const SizedBox(height: 4),
                Text(
                  _erro!,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _buscando || _validandoIp
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _selecionada == null || _buscando || _validandoIp
              ? null
              : () => Navigator.of(context).pop(_selecionada),
          icon: const Icon(Icons.link_rounded),
          label: const Text('Parear'),
        ),
      ],
    );
  }
}

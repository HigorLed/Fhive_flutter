import 'package:flutter/material.dart';

/// Diálogo de texto simples. O controller pertence ao State do diálogo,
/// então é descartado só quando o diálogo sai da árvore (sem crash de
/// "TextEditingController used after being disposed").
Future<String?> pedirTexto(
  BuildContext context, {
  required String titulo,
  required String rotulo,
  String? dica,
  IconData? icone,
  String textoConfirmar = 'Adicionar',
  TextInputType? teclado,
  bool barreiraFecha = true,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: barreiraFecha,
    builder: (_) => _DialogoTexto(
      titulo: titulo,
      rotulo: rotulo,
      dica: dica,
      icone: icone,
      textoConfirmar: textoConfirmar,
      teclado: teclado,
    ),
  );
}

class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({
    required this.titulo,
    required this.rotulo,
    required this.textoConfirmar,
    this.dica,
    this.icone,
    this.teclado,
  });

  final String titulo;
  final String rotulo;
  final String? dica;
  final IconData? icone;
  final String textoConfirmar;
  final TextInputType? teclado;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: widget.teclado,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: widget.rotulo,
          hintText: widget.dica,
          prefixIcon: widget.icone == null ? null : Icon(widget.icone),
        ),
        onSubmitted: (valor) => Navigator.of(context).pop(valor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.textoConfirmar),
        ),
      ],
    );
  }
}

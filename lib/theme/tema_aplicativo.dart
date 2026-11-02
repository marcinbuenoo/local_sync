import 'package:flutter/material.dart';

class TemaAplicativo extends InheritedWidget {
  const TemaAplicativo({
    super.key,
    required this.modoEscuro,
    required this.aoAlternar,
    required super.child,
  });

  final bool modoEscuro;
  final VoidCallback aoAlternar;

  static TemaAplicativo of(BuildContext context) {
    final tema = context.dependOnInheritedWidgetOfExactType<TemaAplicativo>();
    assert(tema != null, 'TemaAplicativo não foi encontrado na árvore.');
    return tema!;
  }

  @override
  bool updateShouldNotify(TemaAplicativo oldWidget) {
    return modoEscuro != oldWidget.modoEscuro;
  }
}

class BotaoAlternarTema extends StatelessWidget {
  const BotaoAlternarTema({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = TemaAplicativo.of(context);

    return IconButton(
      tooltip: tema.modoEscuro ? 'Ativar tema claro' : 'Ativar tema escuro',
      onPressed: tema.aoAlternar,
      icon: Icon(tema.modoEscuro ? Icons.light_mode : Icons.dark_mode),
    );
  }
}

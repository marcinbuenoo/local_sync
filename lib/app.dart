import 'package:flutter/material.dart';

import 'features/localizacoes/presentation/screens/tela_coleta.dart';
import 'theme/tema_aplicativo.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _modoEscuro = true;

  void _alternarTema() {
    setState(() {
      _modoEscuro = !_modoEscuro;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TemaAplicativo(
      modoEscuro: _modoEscuro,
      aoAlternar: _alternarTema,
      child: MaterialApp(
        title: 'Localizações',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
            secondary: Colors.teal,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
            secondary: Colors.teal,
          ),
          useMaterial3: true,
        ),
        themeMode: _modoEscuro ? ThemeMode.dark : ThemeMode.light,
        home: const TelaColeta(),
      ),
    );
  }
}

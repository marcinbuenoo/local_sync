import 'package:flutter/material.dart';

import '../../../../theme/tema_aplicativo.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';

class TelaLocalizacoes extends StatefulWidget {
  const TelaLocalizacoes({super.key, required this.coletaAtiva});

  final bool coletaAtiva;

  @override
  State<TelaLocalizacoes> createState() => _TelaLocalizacoesState();
}

class _TelaLocalizacoesState extends State<TelaLocalizacoes> {
  final _repositorio = RepositorioLocalizacoes();

  List<Localizacao> _localizacoes = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar({bool mostrarIndicador = false}) async {
    if (mostrarIndicador) {
      setState(() {
        _carregando = true;
      });
    }

    try {
      final localizacoes = await _repositorio.buscarUltimas();

      if (!mounted) return;

      setState(() {
        _localizacoes = localizacoes;
        _erro = null;
        _carregando = false;
      });
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível carregar o histórico: $erro';
        _carregando = false;
      });
    }
  }

  Future<void> _confirmarLimpeza() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: Text(
          'Esta operação é permanente e apagará todos os registros, '
          'inclusive os que não aparecem nesta lista.'
          '${widget.coletaAtiva ? '\n\nA coleta está ativa; novos registros continuarão sendo salvos.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar histórico'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _repositorio.limpar();

      if (!mounted) return;

      setState(() {
        _localizacoes = [];
        _erro = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Histórico limpo com sucesso.')),
      );
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao limpar o histórico: $erro')),
      );
    }
  }

  String _formatarInstante(DateTime instante) {
    final local = instante.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    final segundo = local.second.toString().padLeft(2, '0');

    return '$dia/$mes/${local.year} $hora:$minuto:$segundo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          const BotaoAlternarTema(),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => _carregar(mostrarIndicador: true),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Limpar histórico',
            onPressed: _confirmarLimpeza,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: _carregando && _localizacoes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _erro != null && _localizacoes.isEmpty
          ? Center(
              child: TextButton(
                onPressed: () => _carregar(mostrarIndicador: true),
                child: Text(_erro!),
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregar,
              child: _localizacoes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Center(
                          child: Text('Ainda não há localizações salvas.'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _localizacoes.length,
                      itemBuilder: (context, indice) {
                        final localizacao = _localizacoes[indice];

                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(_formatarInstante(localizacao.instante)),
                          subtitle: Text(
                            'Lat: ${localizacao.latitude.toStringAsFixed(6)}  '
                            'Lon: ${localizacao.longitude.toStringAsFixed(6)}\n'
                            'Precisão: ${localizacao.precisao.toStringAsFixed(1)} m',
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
            ),
    );
  }
}

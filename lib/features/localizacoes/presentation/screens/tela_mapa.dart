import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../theme/tema_aplicativo.dart';
import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';
import '../widgets/mapa_localizacoes.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _repositorio = RepositorioLocalizacoes();
  final _controladorMapa = MapController();

  List<Localizacao> _localizacoes = [];
  MapCachingProvider? _cacheProvider;
  bool _carregando = true;
  bool _mapaPronto = false;
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
      final cache = await CacheMapa.preparar();
      final localizacoes = await _repositorio.buscarUltimas();

      if (!mounted) return;

      setState(() {
        _cacheProvider = cache;
        _localizacoes = localizacoes;
        _erro = null;
        _carregando = false;
      });

      if (_mapaPronto && localizacoes.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _enquadrarPontos();
        });
      }
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível carregar o mapa: $erro';
        _carregando = false;
      });

      if (_cacheProvider != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_erro!)),
        );
      }
    }
  }

  void _enquadrarPontos() {
    if (!_mapaPronto || _localizacoes.isEmpty) return;

    final pontos = _localizacoes
        .map((localizacao) => LatLng(localizacao.latitude, localizacao.longitude))
        .toList(growable: false);

    _controladorMapa.fitCamera(
      CameraFit.coordinates(
        coordinates: pontos,
        padding: const EdgeInsets.all(56),
        maxZoom: 16,
      ),
    );
  }

  void _aoMapaPronto() {
    if (_mapaPronto) return;
    setState(() {
      _mapaPronto = true;
    });
  }

  @override
  void dispose() {
    _controladorMapa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cacheDisponivel = _cacheProvider != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de localizações'),
        actions: const [BotaoAlternarTema()],
      ),
      body: _carregando && !cacheDisponivel
          ? const Center(child: CircularProgressIndicator())
          : _erro != null && !cacheDisponivel
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_erro!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              _carregar(mostrarIndicador: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : _localizacoes.isEmpty
                  ? const Center(
                      child: Text('Nenhuma localização salva para mostrar.'),
                    )
                  : MapaLocalizacoes(
                      localizacoes: _localizacoes,
                      cacheProvider: _cacheProvider!,
                      controller: _controladorMapa,
                      onMapReady: _aoMapaPronto,
                    ),
      floatingActionButton: _localizacoes.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'reenquadrarPontos',
                  tooltip: 'Enquadrar todos os pontos',
                  onPressed: _enquadrarPontos,
                  child: const Icon(Icons.fit_screen),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  heroTag: 'atualizarMapa',
                  tooltip: 'Atualizar localizações',
                  onPressed: _carregando
                      ? null
                      : () => _carregar(mostrarIndicador: true),
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
    );
  }
}

import 'tela_localizacoes.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/servico_localizacao.dart';

class TelaColeta extends StatefulWidget {
  const TelaColeta({super.key});

  @override
  State<TelaColeta> createState() => _TelaColetaState();
}

class _TelaColetaState extends State<TelaColeta> {
  final _servico = ServicoLocalizacao();
  final _repositorio = RepositorioLocalizacoes();

  StreamSubscription<Position>? _assinatura;
  Position? _ultimaPosicao;
  String? _erro;
  bool _iniciando = false;

  bool get _coletando => _assinatura != null;

  Future<void> _iniciarColeta() async {
    if (_coletando || _iniciando) return;

    setState(() {
      _iniciando = true;
      _erro = null;
    });

    try {
      await _servico.prepararColeta();

      if (!mounted) return;

      final streamComGravacao = _servico.acompanharPosicoes().asyncMap((
        posicao,
      ) async {
        await _repositorio.inserir(
          Localizacao(
            latitude: posicao.latitude,
            longitude: posicao.longitude,
            precisao: posicao.accuracy,
            instante: posicao.timestamp,
          ),
        );

        return posicao;
      });

      final assinatura = streamComGravacao.listen(
        (posicao) {
          if (!mounted) return;

          setState(() {
            _ultimaPosicao = posicao;
          });
        },
        onError: (Object erro) {
          if (!mounted) return;

          setState(() {
            _erro = 'Erro ao receber ou salvar localização: $erro';
            _assinatura = null;
          });
        },
        cancelOnError: true,
      );

      setState(() {
        _assinatura = assinatura;
      });
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        _erro = erro.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _iniciando = false;
        });
      }
    }
  }

  Future<void> _pararColeta() async {
    final assinatura = _assinatura;
    if (assinatura == null) return;

    setState(() {
      _assinatura = null;
    });

    await assinatura.cancel();
  }

  @override
  void dispose() {
    unawaited(_assinatura?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coleta de localizações')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _coletando ? 'Coleta ativa' : 'Coleta parada',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: (_coletando || _iniciando) ? null : _iniciarColeta,
              icon: const Icon(Icons.play_arrow),
              label: Text(_iniciando ? 'Iniciando...' : 'Iniciar coleta'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _coletando ? _pararColeta : null,
              icon: const Icon(Icons.stop),
              label: const Text('Parar coleta'),
            ),
            const SizedBox(height: 24),
            if (_ultimaPosicao case final posicao?)
              Text(
                'Última posição salva:\n'
                'Latitude: ${posicao.latitude.toStringAsFixed(6)}\n'
                'Longitude: ${posicao.longitude.toStringAsFixed(6)}\n'
                'Precisão: ${posicao.accuracy.toStringAsFixed(1)} m',
                textAlign: TextAlign.center,
              ),
            if (_erro != null) ...[
              const SizedBox(height: 16),
              Text(
                _erro!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
            const Spacer(),
            TextButton.icon(
              onPressed: _servico.abrirConfiguracoesPermissao,
              icon: const Icon(Icons.settings),
              label: const Text('Configurações de permissão'),
            ),
            TextButton.icon(
              onPressed: _servico.abrirConfiguracoesLocalizacao,
              icon: const Icon(Icons.location_searching),
              label: const Text('Configurações de localização'),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      TelaLocalizacoes(coletaAtiva: _coletando),
                ),
              );
            },
            icon: const Icon(Icons.history),
            label: const Text('Consultar histórico'),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class ServicoLocalizacao {
  Future<void> prepararColeta() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      throw Exception('Ative o serviço de localização do aparelho.');
    }

    var permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw Exception('A permissão de localização foi negada.');
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'A permissão foi negada permanentemente. '
        'Habilite-a nas configurações do aplicativo.',
      );
    }
  }

  Stream<Position> acompanharPosicoes() {
    late final LocationSettings configuracoes;

    if (defaultTargetPlatform == TargetPlatform.android) {
      configuracoes = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 20),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Coleta de localização ativa',
          notificationText: 'O aplicativo está registrando sua localização.',
          enableWakeLock: true,
        ),
      );
    } else {
      configuracoes = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.other,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }

    return Geolocator.getPositionStream(locationSettings: configuracoes);
  }

  Future<bool> abrirConfiguracoesPermissao() {
    return Geolocator.openAppSettings();
  }

  Future<bool> abrirConfiguracoesLocalizacao() {
    return Geolocator.openLocationSettings();
  }
}

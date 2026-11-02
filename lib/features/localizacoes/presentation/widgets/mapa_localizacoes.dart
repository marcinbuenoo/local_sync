import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/localizacao.dart';

class MapaLocalizacoes extends StatelessWidget {
  const MapaLocalizacoes({
    super.key,
    required this.localizacoes,
    required this.cacheProvider,
    required this.controller,
    required this.onMapReady,
  });

  final List<Localizacao> localizacoes;
  final MapCachingProvider cacheProvider;
  final MapController controller;
  final VoidCallback onMapReady;

  @override
  Widget build(BuildContext context) {
    final pontos = localizacoes
        .map((localizacao) => LatLng(localizacao.latitude, localizacao.longitude))
        .toList(growable: false);

    final marcadores = List<Marker>.generate(localizacoes.length, (indice) {
      final localizacao = localizacoes[indice];

      return Marker(
        point: LatLng(localizacao.latitude, localizacao.longitude),
        width: 42,
        height: 42,
        child: Icon(
          Icons.location_pin,
          size: 38,
          color: indice == 0 ? Colors.red : Colors.teal,
        ),
      );
    });

    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCameraFit: CameraFit.coordinates(
          coordinates: pontos,
          padding: const EdgeInsets.all(56),
          maxZoom: 16,
        ),
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.local_sync',
          tileProvider: NetworkTileProvider(
            cachingProvider: cacheProvider,
          ),
        ),
        MarkerLayer(markers: marcadores),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

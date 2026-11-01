import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheMapa {
  static Future<MapCachingProvider> preparar() async {
    final diretorioPrivado = await getApplicationSupportDirectory();
    final diretorioCache = Directory(
      p.join(diretorioPrivado.path, 'cache_mapa'),
    );

    await diretorioCache.create(recursive: true);

    return BuiltInMapCachingProvider.getOrCreateInstance(
      cacheDirectory: diretorioCache.path,
      maxCacheSize: 250 * 1024 * 1024,
    );
  }
}

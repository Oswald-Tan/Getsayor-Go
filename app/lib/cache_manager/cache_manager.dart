import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheManager extends CacheManager {
  static const key = 'appGlobalCache'; // Nama unik untuk cache

  static final AppCacheManager _instance = AppCacheManager._();

  factory AppCacheManager() => _instance;

  AppCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30), // Cache 30 hari untuk semua
          maxNrOfCacheObjects: 200, // Maksimal 200 file di cache
        ));
}

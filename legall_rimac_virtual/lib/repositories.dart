import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legall_rimac_virtual/repositories/repositories.dart';
import 'package:legall_rimac_virtual/storage/firebase_storage_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<RepositoryProvider> getRepositoryProviders(final SharedPreferences preferences) {
  return [
    RepositoryProvider<SettingsRepository>(
      create: (context) => SettingsRepository(preferences),
    ),
    RepositoryProvider<BrandsRepository>(
      create: (context) => BrandsRepository()
    ),
    RepositoryProvider<ChatsRepository>(
      create: (context) => ChatsRepository()
    ),
    RepositoryProvider<InspectionsRepository>(
      create: (context) => InspectionsRepository()
    ),
    RepositoryProvider<PhotosRepository>(
      create: (context) => PhotosRepository(
        storage: FirebaseStorageStorage()
      ),
    ),
    RepositoryProvider<VideosRepository>(
      create: (context) => VideosRepository(
          storage: FirebaseStorageStorage()
      ),
    )
  ];
}
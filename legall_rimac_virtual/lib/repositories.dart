import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:legall_rimac_virtual/repositories/settings_repository.dart';

List<RepositoryProvider> getRepositoryProviders(final SharedPreferences preferences) {
  return [
    RepositoryProvider<SettingsRepository>(
      create: (context) => SettingsRepository(preferences),
    )/*,
    RepositoryProvider<AccountRepository>(
      create: (context) => AccountRepository(),
    ),
    RepositoryProvider<RaffleCategoriesRepository>(
        create: (context) => FirebaseRaffleCategoriesRepository()
    ),
    RepositoryProvider<RafflesRepository>(
        create: (context) => FirebaseRafflesRepository()
    ),
    RepositoryProvider<PaymentMethodsRepository>(
      create: (context) => FirebasePaymentMethodsRepository()
    ),
    RepositoryProvider<TransactionsRepository>(
      create: (context) => FirebaseTransactionsRepository()
    )*/
  ];
}
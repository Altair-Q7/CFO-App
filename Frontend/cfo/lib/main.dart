import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/storage/token_storage.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIXED BUG-001: initialize token storage before runApp
  final tokenStorage = TokenStorage();
  await tokenStorage.loadCachedData();

  runApp(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokenStorage),
      ],
      child: const CfoApp(),
    ),
  );
}

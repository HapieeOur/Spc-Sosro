import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/app.dart';
import 'package:spc_sosro/core/config/app_env.dart';
import 'package:spc_sosro/core/supabase_config.dart';
import 'package:spc_sosro/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final url = AppEnv.isConfigured ? AppEnv.supabaseUrl : SupabaseConfig.url;
  final key = AppEnv.isConfigured ? AppEnv.supabaseAnonKey : SupabaseConfig.publishableKey;

  await SupabaseService.initialize(
    url: url,
    anonKey: key,
  );

  runApp(
    const ProviderScope(
      child: SpcSosroApp(),
    ),
  );
}

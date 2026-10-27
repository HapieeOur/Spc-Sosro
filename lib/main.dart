import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spc_sosro/app.dart';
import 'package:spc_sosro/core/config/app_env.dart';
import 'package:spc_sosro/core/supabase_config.dart';
import 'package:spc_sosro/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale bahasa Indonesia untuk format tanggal
  await initializeDateFormatting('id_ID', null);

  // Penanganan error UI agar tidak muncul layar abu-abu polos jika terjadi error
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Terjadi Kesalahan Tampilan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  };

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

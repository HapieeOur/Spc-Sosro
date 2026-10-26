import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/models/activity_log.dart';
import 'package:spc_sosro/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getSettings();
});

final activityLogsProvider = FutureProvider.autoDispose<List<ActivityLog>>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.fetchActivityLogs();
});

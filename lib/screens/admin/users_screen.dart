import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/models/profile.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/widgets/confirm_dialog.dart';
import 'package:spc_sosro/widgets/empty_state.dart';
import 'package:spc_sosro/widgets/error_view.dart';
import 'package:spc_sosro/widgets/loading_view.dart';

final allProfilesProvider = FutureProvider.autoDispose<List<Profile>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchAllProfiles();
});

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSetUserStatus(Profile user, bool newStatus) async {
    final actionName = newStatus ? 'menyetujui (ACC)' : 'menonaktifkan';
    final confirmed = await ConfirmDialog.show(
      context,
      title: newStatus ? 'Persetujuan Pengguna' : 'Nonaktifkan Pengguna',
      message: 'Apakah Anda yakin ingin $actionName akun ${user.fullName}?',
      confirmText: newStatus ? 'Ya, Setujui (ACC)' : 'Ya, Nonaktifkan',
      isDestructive: !newStatus,
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(profileRepositoryProvider)
            .setUserStatus(userId: user.id, isActive: newStatus);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newStatus
                    ? 'Akun ${user.fullName} berhasil di-ACC!'
                    : 'Akun ${user.fullName} telah dinonaktifkan.',
              ),
              backgroundColor: newStatus ? AppColors.daun : AppColors.bata,
            ),
          );
          ref.invalidate(allProfilesProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui status: $e'),
              backgroundColor: AppColors.bata,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(allProfilesProvider);

    return Scaffold(
      backgroundColor: AppColors.kertas,
      appBar: AppBar(
        title: const Text(
          'Kelola & Persetujuan Pengguna',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.tinta,
          ),
        ),
        backgroundColor: AppColors.permukaan,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: profilesAsync.when(
            data: (profiles) {
              final pendingCount = profiles.where((p) => !p.isActive).length;
              return TabBar(
                controller: _tabController,
                indicatorColor: AppColors.daun,
                labelColor: AppColors.daun,
                unselectedLabelColor: AppColors.abuTinta,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Menunggu ACC'),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.kuningMarka,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$pendingCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(text: 'Semua Pengguna (${profiles.length})'),
                ],
              );
            },
            loading: () => const TabBar(
              tabs: [
                Tab(text: 'Menunggu ACC'),
                Tab(text: 'Semua Pengguna'),
              ],
            ),
            error: (_, unused) => const SizedBox(),
          ),
        ),
      ),
      body: profilesAsync.when(
        data: (profiles) {
          final pendingUsers = profiles.where((p) => !p.isActive).toList();
          final filteredAllUsers = profiles.where((p) {
            if (_searchQuery.isEmpty) return true;
            return p.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.email.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: PENDING ACC
              _buildPendingTab(pendingUsers),

              // TAB 2: SEMUA USER
              _buildAllUsersTab(filteredAllUsers),
            ],
          );
        },
        loading: () => const LoadingView(message: 'Memuat data pengguna...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(allProfilesProvider),
        ),
      ),
    );
  }

  Widget _buildPendingTab(List<Profile> pendingUsers) {
    if (pendingUsers.isEmpty) {
      return const EmptyState(
        title: 'Tidak Ada Antrean ACC',
        subtitle: 'Semua akun operator yang terdaftar telah disetujui.',
        icon: Icons.check_circle_outline,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pendingUsers.length,
      separatorBuilder: (_, unused) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = pendingUsers[index];
        return Card(
          color: AppColors.permukaan,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.garis),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.kuningMarkaMuda,
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.teksPeringatan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tinta,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.abuTinta,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mendaftar: ${DateFormatter.formatDateTime(user.createdAt)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.abuTinta,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.kuningMarkaMuda,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.kuningMarka.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Menunggu ACC',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teksPeringatan,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.garis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.daun,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text(
                          'ACC / Setujui Akun',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _handleSetUserStatus(user, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllUsersTab(List<Profile> users) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama atau email pengguna...',
              prefixIcon: const Icon(Icons.search, color: AppColors.abuTinta),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.abuTinta),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.permukaan,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.garis),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.garis),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
          ),
        ),

        // List
        Expanded(
          child: users.isEmpty
              ? const EmptyState(
                  title: 'Pengguna Tidak Ditemukan',
                  subtitle: 'Tidak ada data pengguna yang sesuai dengan pencarian.',
                  icon: Icons.person_off_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, unused) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isAdmin = user.role == AppRole.admin;

                    return Card(
                      color: AppColors.permukaan,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.garis),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  isAdmin ? AppColors.daunMuda : AppColors.kertas,
                              child: Icon(
                                isAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.person_outline,
                                color: isAdmin ? AppColors.daun : AppColors.abuTinta,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.fullName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.tinta,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isAdmin
                                              ? AppColors.daunTua
                                              : AppColors.kertas,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isAdmin ? 'ADMIN' : 'OPERATOR',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isAdmin
                                                ? Colors.white
                                                : AppColors.abuTinta,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.abuTinta,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status & Switch
                            if (!isAdmin) ...[
                              Switch(
                                value: user.isActive,
                                activeThumbColor: AppColors.daun,
                                onChanged: (newVal) =>
                                    _handleSetUserStatus(user, newVal),
                              ),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.daunMuda,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Aktif',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.daunTua,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

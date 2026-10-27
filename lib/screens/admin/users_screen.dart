import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/date_formatter.dart';
import 'package:spc_sosro/core/utils/validators.dart';
import 'package:spc_sosro/models/profile.dart';
import 'package:spc_sosro/providers/auth_provider.dart';
import 'package:spc_sosro/widgets/app_button.dart';
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
                    ? 'Akun ${user.fullName} berhasil disetujui (ACC)!'
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

  void _showUserDetailSheet(Profile user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isAdmin = user.role == AppRole.admin;
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.permukaan,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.garis,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isAdmin ? AppColors.merahMuda : AppColors.kertas,
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: isAdmin ? AppColors.merahSosro : AppColors.abuTinta,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tinta,
                          ),
                        ),
                        Text(
                          user.email,
                          style: const TextStyle(fontSize: 13, color: AppColors.abuTinta),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isActive ? AppColors.daunMuda : AppColors.kuningMarkaMuda,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.isActive ? 'AKTIF' : 'MENUNGGU ACC',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: user.isActive ? AppColors.daunTua : AppColors.teksPeringatan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.garis),
              const SizedBox(height: 16),

              // Rincian Detail Akun
              _buildDetailItem(
                icon: Icons.badge_outlined,
                title: 'Peran / Role',
                value: isAdmin ? 'Administrator Gudang' : 'Operator Tally Lapangan',
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.calendar_today_outlined,
                title: 'Waktu Mendaftar',
                value: DateFormatter.formatDateTime(user.createdAt),
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.update_outlined,
                title: 'Terakhir Diperbarui',
                value: DateFormatter.formatDateTime(user.updatedAt),
              ),
              const SizedBox(height: 12),
              _buildDetailItem(
                icon: Icons.lock_outline,
                title: 'Kata Sandi (Password)',
                value: '••••••••••••',
                subtitle: 'Kata sandi dienkripsi otomatis oleh sistem autentikasi dan tidak dapat dilihat oleh siapa pun demi keamanan.',
                valueColor: AppColors.abuTinta,
              ),
              const SizedBox(height: 24),

              // Tombol Aksi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.merahSosro,
                        side: const BorderSide(color: AppColors.merahSosro),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditUserSheet(user);
                      },
                    ),
                  ),
                  if (!user.isActive) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.daun,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('ACC Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _handleSetUserStatus(user, true);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditUserSheet(Profile user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditUserSheet(
        user: user,
        onSaved: () => ref.invalidate(allProfilesProvider),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.kertas,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.merahSosro),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.tinta,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.abuTinta, height: 1.2),
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
                indicatorColor: AppColors.merahSosro,
                labelColor: AppColors.merahSosro,
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
                              color: AppColors.merahSosro,
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
        return InkWell(
          onTap: () => _showUserDetailSheet(user),
          borderRadius: BorderRadius.circular(10),
          child: Card(
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
                                fontSize: 15,
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
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.garis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.tinta,
                            side: const BorderSide(color: AppColors.garis),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.info_outline, size: 16),
                          label: const Text('Detail & Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          onPressed: () => _showUserDetailSheet(user),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.daun,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('ACC Akun', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => _handleSetUserStatus(user, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                      child: InkWell(
                        onTap: () => _showUserDetailSheet(user),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    isAdmin ? AppColors.merahMuda : AppColors.kertas,
                                child: Icon(
                                  isAdmin
                                      ? Icons.admin_panel_settings
                                      : Icons.person_outline,
                                  color: isAdmin ? AppColors.merahSosro : AppColors.abuTinta,
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
                                              fontSize: 14,
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
                                                ? AppColors.merahSosro
                                                : AppColors.kertas,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isAdmin ? 'ADMIN' : 'OPERATOR',
                                            style: TextStyle(
                                              fontSize: 9.5,
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

                              // Tombol Edit
                              IconButton(
                                tooltip: 'Edit Pengguna',
                                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.abuTinta),
                                onPressed: () => _showEditUserSheet(user),
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Lembar Form Edit Pengguna
class _EditUserSheet extends ConsumerStatefulWidget {
  final Profile user;
  final VoidCallback onSaved;

  const _EditUserSheet({
    required this.user,
    required this.onSaved,
  });

  @override
  ConsumerState<_EditUserSheet> createState() => _EditUserSheetState();
}

class _EditUserSheetState extends ConsumerState<_EditUserSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late AppRole _selectedRole;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(profileRepositoryProvider).adminUpdateProfile(
            userId: widget.user.id,
            fullName: _nameController.text.trim(),
            role: _selectedRole.name,
            isActive: _isActive,
          );

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Akun ${_nameController.text.trim()} berhasil diperbarui!'),
            backgroundColor: AppColors.daun,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui akun: $e'),
            backgroundColor: AppColors.bata,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.garis,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Edit Akun Pengguna',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tinta,
                ),
              ),
              Text(
                'Email: ${widget.user.email}',
                style: const TextStyle(fontSize: 12, color: AppColors.abuTinta),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.garis),
              const SizedBox(height: 16),

              // Input Nama Lengkap
              const Text(
                'Nama Lengkap',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tinta),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap...',
                  filled: true,
                  fillColor: AppColors.kertas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.garis),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.garis),
                  ),
                ),
                validator: (val) => Validators.validateRequired(val, fieldName: 'Nama Lengkap'),
              ),
              const SizedBox(height: 16),

              // Pilihan Role
              const Text(
                'Peran / Role',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tinta),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<AppRole>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.kertas,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.garis),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.garis),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: AppRole.operator,
                    child: Text('Operator Lapangan (Tally)'),
                  ),
                  DropdownMenuItem(
                    value: AppRole.admin,
                    child: Text('Administrator Gudang'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRole = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Status Akun Aktif
              Container(
                decoration: BoxDecoration(
                  color: AppColors.kertas,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.garis),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Status Akun Aktif',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tinta),
                  ),
                  subtitle: Text(
                    _isActive ? 'Pengguna dapat masuk dan mencatat' : 'Pengguna diblokir / menunggu ACC',
                    style: const TextStyle(fontSize: 11, color: AppColors.abuTinta),
                  ),
                  value: _isActive,
                  activeThumbColor: AppColors.daun,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ),
              const SizedBox(height: 14),

              // Catatan Password
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kuningMarkaMuda,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.kuningMarka.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 18, color: AppColors.teksPeringatan),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kata sandi dienkripsi aman dan tidak dapat dilihat atau diubah melalui menu ini.',
                        style: TextStyle(fontSize: 11, color: AppColors.teksPeringatan, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Simpan
              AppButton(
                text: 'Simpan Perubahan',
                icon: Icons.save_outlined,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spc_sosro/core/theme/app_colors.dart';
import 'package:spc_sosro/core/utils/validators.dart';
import 'package:spc_sosro/models/product.dart';
import 'package:spc_sosro/providers/products_provider.dart';
import 'package:spc_sosro/widgets/app_button.dart';
import 'package:spc_sosro/widgets/app_text_field.dart';
import 'package:spc_sosro/widgets/empty_state.dart';
import 'package:spc_sosro/widgets/error_view.dart';
import 'package:spc_sosro/widgets/loading_view.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProductDialog([Product? product]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductFormSheet(
        product: product,
        onSaved: () => ref.invalidate(allProductsProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Master Produk',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: AppColors.tinta,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: _isGridView ? 'Tampilan List' : 'Tampilan Grid',
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.abuTinta,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.merahSosro,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Tambah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () => _openProductDialog(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (Gaya Membulat seperti pada referensi "Product Feed")
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari kode atau nama produk Sosro...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.abuTinta, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.abuTinta, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              ),
            ),
          ),

          // Product Feed
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filtered = products.where((p) {
                  if (_searchQuery.isEmpty) return true;
                  return p.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      p.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyState(
                    title: 'Produk Tidak Ditemukan',
                    subtitle: _searchQuery.isEmpty
                        ? 'Belum ada produk yang terdaftar di sistem.'
                        : 'Tidak ada produk yang cocok dengan pencarian.',
                    icon: Icons.inventory_2_outlined,
                    actionText: 'Tambah Produk Baru',
                    onAction: () => _openProductDialog(),
                  );
                }

                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildGridProductCard(filtered[index]);
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildListProductCard(filtered[index]);
                  },
                );
              },
              loading: () => const LoadingView(message: 'Memuat data produk...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(allProductsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kartu Grid 2 Kolom (Persis seperti "Product Feed" pada referensi gambar)
  Widget _buildGridProductCard(Product product) {
    return InkWell(
      onTap: () => _openProductDialog(product),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container Gambar / Ikon Produk ala Kartu E-Commerce/Feed
            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.merahMuda,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 42,
                  color: AppColors.merahSosro.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Badge Kode Produk
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                product.code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.merahSosro,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Nama Produk
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.tinta,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Kapasitas Palet & Tombol Edit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.boxesPerPallet} Dus',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.merahSosro,
                      ),
                    ),
                    Text(
                      '${product.rowsPerPallet}b × ${product.boxesPerRow}d',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.merahMuda,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 15,
                    color: AppColors.merahSosro,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Kartu List 1 Kolom (Opsional / Alternatif)
  Widget _buildListProductCard(Product product) {
    return InkWell(
      onTap: () => _openProductDialog(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.merahMuda,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.merahSosro,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.merahSosro,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tinta,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kapasitas: ${product.boxesPerPallet} dus (${product.rowsPerPallet} baris × ${product.boxesPerRow} dus)',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _ProductFormSheet extends ConsumerStatefulWidget {
  final Product? product;
  final VoidCallback onSaved;

  const _ProductFormSheet({this.product, required this.onSaved});

  @override
  ConsumerState<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _rowsController;
  late TextEditingController _boxesPerRowController;
  late TextEditingController _minStockController;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _codeController = TextEditingController(text: p?.code ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _rowsController = TextEditingController(text: p != null ? '${p.rowsPerPallet}' : '5');
    _boxesPerRowController = TextEditingController(text: p != null ? '${p.boxesPerRow}' : '10');
    _minStockController = TextEditingController(text: p != null ? '${p.minStockBoxes}' : '50');
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _rowsController.dispose();
    _boxesPerRowController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await ref.read(productRepositoryProvider).adminSaveProduct(
              productId: widget.product?.id,
              code: _codeController.text.trim().toUpperCase(),
              name: _nameController.text.trim(),
              rowsPerPallet: int.parse(_rowsController.text.trim()),
              boxesPerRow: int.parse(_boxesPerRowController.text.trim()),
              minStockBoxes: int.parse(_minStockController.text.trim()),
              isActive: _isActive,
            );

        widget.onSaved();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null
                    ? 'Produk baru berhasil ditambahkan!'
                    : 'Data produk berhasil diperbarui!',
              ),
              backgroundColor: AppColors.daun,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan produk: $e'),
              backgroundColor: AppColors.bata,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Produk' : 'Tambah Produk Baru',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tinta,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kode Produk
              AppTextField(
                controller: _codeController,
                label: 'Kode Produk',
                hint: 'Contoh: TBS-250',
                validator: (v) => Validators.validateRequired(v, fieldName: 'Kode Produk'),
              ),
              const SizedBox(height: 14),

              // Nama Produk
              AppTextField(
                controller: _nameController,
                label: 'Nama Produk',
                hint: 'Contoh: Teh Botol Sosro Kotak 250ml',
                validator: (v) => Validators.validateRequired(v, fieldName: 'Nama Produk'),
              ),
              const SizedBox(height: 14),

              // Konfigurasi Palet
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _rowsController,
                      label: 'Baris / Palet',
                      hint: '5',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.validatePositiveInt(v, fieldName: 'Baris'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _boxesPerRowController,
                      label: 'Dus / Baris',
                      hint: '10',
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.validatePositiveInt(v, fieldName: 'Dus/baris'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Min Stok
              AppTextField(
                controller: _minStockController,
                label: 'Batas Minimum Stok Gudang (Dus)',
                hint: 'Contoh: 100',
                keyboardType: TextInputType.number,
                validator: (v) => Validators.validatePositiveInt(v, fieldName: 'Min. stok'),
              ),
              const SizedBox(height: 14),

              // Status Aktif
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status Produk Aktif',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.tinta,
                    ),
                  ),
                  Switch(
                    value: _isActive,
                    activeThumbColor: AppColors.daun,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              AppButton(
                text: isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
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

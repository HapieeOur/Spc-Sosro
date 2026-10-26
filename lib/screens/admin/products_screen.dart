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
      backgroundColor: AppColors.kertas,
      appBar: AppBar(
        title: const Text(
          'Master Produk & Palet',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.tinta,
          ),
        ),
        backgroundColor: AppColors.permukaan,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Tambah Produk',
            icon: const Icon(Icons.add_circle, color: AppColors.daun, size: 28),
            onPressed: () => _openProductDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kode atau nama produk...',
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

          // Product List
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

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return _buildProductCard(product);
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

  Widget _buildProductCard(Product product) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.kertas,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.garis),
                        ),
                        child: Text(
                          product.code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.tinta,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tinta,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit Produk',
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.abuTinta),
                  onPressed: () => _openProductDialog(product),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.garis),
            const SizedBox(height: 12),

            // Spesifikasi Palet Grid
            Row(
              children: [
                _buildSpecItem(
                  label: 'Susunan Palet',
                  value: '${product.rowsPerPallet} baris × ${product.boxesPerRow} dus',
                ),
                _buildSpecItem(
                  label: 'Kapasitas Palet',
                  value: '${product.boxesPerPallet} dus / palet',
                  isBold: true,
                ),
                _buildSpecItem(
                  label: 'Min. Stok',
                  value: '${product.minStockBoxes} dus',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem({required String label, required String value, bool isBold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.abuTinta,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.tinta,
            ),
          ),
        ],
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:spc_sosro/core/constants/app_constants.dart';
import 'package:spc_sosro/core/errors/app_exception.dart';
import 'package:spc_sosro/core/utils/quantity_calculator.dart';
import 'package:spc_sosro/models/product.dart';
import 'package:spc_sosro/repositories/transaction_repository.dart';

class TransactionFormLine {
  final Product? product;
  final int fullPallets;
  final int looseRows;
  final int looseBoxes;

  const TransactionFormLine({
    this.product,
    this.fullPallets = 0,
    this.looseRows = 0,
    this.looseBoxes = 0,
  });

  int get totalBoxes {
    if (product == null) return 0;
    return QuantityCalculator.calculateTotalBoxes(
      fullPallets: fullPallets,
      looseRows: looseRows,
      looseBoxes: looseBoxes,
      rowsPerPallet: product!.rowsPerPallet,
      boxesPerRow: product!.boxesPerRow,
    );
  }

  TransactionFormLine copyWith({
    Product? product,
    int? fullPallets,
    int? looseRows,
    int? looseBoxes,
  }) {
    return TransactionFormLine(
      product: product ?? this.product,
      fullPallets: fullPallets ?? this.fullPallets,
      looseRows: looseRows ?? this.looseRows,
      looseBoxes: looseBoxes ?? this.looseBoxes,
    );
  }
}

class TransactionFormState {
  final TransactionType type;
  final String note;
  final List<TransactionFormLine> lines;
  final String clientRequestId;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? successResult;

  const TransactionFormState({
    required this.type,
    this.note = '',
    required this.lines,
    required this.clientRequestId,
    this.isLoading = false,
    this.errorMessage,
    this.successResult,
  });

  int get grandTotalBoxes => lines.fold(0, (sum, l) => sum + l.totalBoxes);

  bool get canAddLine => lines.length < AppConstants.maxProductsPerTransaction;
  bool get canRemoveLine => lines.length > 1;

  TransactionFormState copyWith({
    TransactionType? type,
    String? note,
    List<TransactionFormLine>? lines,
    String? clientRequestId,
    bool? isLoading,
    String? errorMessage,
    Map<String, dynamic>? successResult,
  }) {
    return TransactionFormState(
      type: type ?? this.type,
      note: note ?? this.note,
      lines: lines ?? this.lines,
      clientRequestId: clientRequestId ?? this.clientRequestId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successResult: successResult,
    );
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  final TransactionRepository _repository;

  TransactionFormNotifier(this._repository, TransactionType type)
      : super(TransactionFormState(
          type: type,
          lines: const [TransactionFormLine()],
          clientRequestId: const Uuid().v4(),
        ));

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  void addLine() {
    if (!state.canAddLine) return;
    state = state.copyWith(
      lines: [...state.lines, const TransactionFormLine()],
    );
  }

  void removeLine(int index) {
    if (!state.canRemoveLine) return;
    final updated = [...state.lines]..removeAt(index);
    state = state.copyWith(lines: updated);
  }

  void updateProduct(int index, Product? product) {
    if (index < 0 || index >= state.lines.length) return;
    final updated = [...state.lines];
    updated[index] = updated[index].copyWith(product: product);
    state = state.copyWith(lines: updated);
  }

  void updateFullPallets(int index, int val) {
    if (index < 0 || index >= state.lines.length) return;
    final updated = [...state.lines];
    updated[index] = updated[index].copyWith(fullPallets: val < 0 ? 0 : val);
    state = state.copyWith(lines: updated);
  }

  void updateLooseRows(int index, int val) {
    if (index < 0 || index >= state.lines.length) return;
    final updated = [...state.lines];
    updated[index] = updated[index].copyWith(looseRows: val < 0 ? 0 : val);
    state = state.copyWith(lines: updated);
  }

  void updateLooseBoxes(int index, int val) {
    if (index < 0 || index >= state.lines.length) return;
    final updated = [...state.lines];
    updated[index] = updated[index].copyWith(looseBoxes: val < 0 ? 0 : val);
    state = state.copyWith(lines: updated);
  }

  Future<bool> submit() async {
    // Validation
    for (final line in state.lines) {
      if (line.product == null) {
        state = state.copyWith(errorMessage: 'Pilih produk untuk semua baris');
        return false;
      }
      if (line.totalBoxes <= 0) {
        state = state.copyWith(errorMessage: 'Total dus untuk setiap produk harus lebih dari 0');
        return false;
      }
    }

    // Check duplicate products
    final productIds = state.lines.map((l) => l.product!.id).toSet();
    if (productIds.length != state.lines.length) {
      state = state.copyWith(errorMessage: 'Produk dalam transaksi tidak boleh duplikat');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final items = state.lines.map((l) {
        return {
          'product_id': l.product!.id,
          'full_pallets': l.fullPallets,
          'loose_rows': l.looseRows,
          'loose_boxes': l.looseBoxes,
        };
      }).toList();

      final result = await _repository.createTransaction(
        type: state.type,
        note: state.note.isEmpty ? null : state.note,
        clientRequestId: state.clientRequestId,
        items: items,
      );

      state = state.copyWith(
        isLoading: false,
        successResult: result,
      );
      return true;
    } catch (e) {
      final message = e is AppException ? e.message : e.toString();
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  void reset() {
    state = TransactionFormState(
      type: state.type,
      lines: const [TransactionFormLine()],
      clientRequestId: const Uuid().v4(),
    );
  }
}

final transactionFormFamily = StateNotifierProvider.autoDispose
    .family<TransactionFormNotifier, TransactionFormState, TransactionType>(
  (ref, type) {
    final repo = ref.watch(transactionRepositoryProvider);
    return TransactionFormNotifier(repo, type);
  },
);

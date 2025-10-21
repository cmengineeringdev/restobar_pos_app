import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/table.dart' as entity;
import '../../domain/usecases/get_all_tables.dart';
import '../../domain/usecases/update_table_status.dart';
import '../../domain/usecases/create_tables_for_point_of_sale.dart';
import 'providers.dart';

class TableState {
  final List<entity.Table> tables;
  final bool isLoading;
  final String? error;

  TableState({
    this.tables = const [],
    this.isLoading = false,
    this.error,
  });

  TableState copyWith({
    List<entity.Table>? tables,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TableState(
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TableStateNotifier extends StateNotifier<TableState> {
  final GetAllTables _getAllTables;
  final UpdateTableStatus _updateTableStatus;
  final CreateTablesForPointOfSale _createTablesForPointOfSale;

  TableStateNotifier(
    this._getAllTables,
    this._updateTableStatus,
    this._createTablesForPointOfSale,
  ) : super(TableState());

  Future<void> loadTables(int pointOfSaleId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tables = await _getAllTables(pointOfSaleId);
      state = state.copyWith(tables: tables, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> updateTableStatus(int tableId, String status) async {
    try {
      await _updateTableStatus(tableId, status);
      
      // Actualizar el estado local
      final updatedTables = state.tables.map((table) {
        if (table.id == tableId) {
          return entity.Table(
            id: table.id,
            number: table.number,
            capacity: table.capacity,
            status: status,
            pointOfSaleId: table.pointOfSaleId,
            createdAt: table.createdAt,
            updatedAt: DateTime.now(),
          );
        }
        return table;
      }).toList();

      state = state.copyWith(tables: updatedTables);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> createTablesForPointOfSale(int pointOfSaleId, int numberOfTables) async {
    try {
      await _createTablesForPointOfSale(pointOfSaleId, numberOfTables);
      await loadTables(pointOfSaleId);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }
}

// Provider
final tableStateProvider = StateNotifierProvider<TableStateNotifier, TableState>((ref) {
  final getAllTables = ref.watch(getAllTablesProvider);
  final updateTableStatus = ref.watch(updateTableStatusProvider);
  final createTablesForPointOfSale = ref.watch(createTablesForPointOfSaleProvider);
  return TableStateNotifier(
    getAllTables,
    updateTableStatus,
    createTablesForPointOfSale,
  );
});


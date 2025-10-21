import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/database/database_service.dart';
import '../../models/work_shift_model.dart';

abstract class WorkShiftLocalDataSource {
  Future<WorkShiftModel?> getActiveWorkShift();
  Future<WorkShiftModel?> getWorkShiftByRemoteId(int remoteId);
  Future<int> insertWorkShift(WorkShiftModel workShift);
  Future<void> updateWorkShift(WorkShiftModel workShift);
  Future<void> closeWorkShift(int localId);
  Future<List<WorkShiftModel>> getAllWorkShifts();
}

class WorkShiftLocalDataSourceImpl implements WorkShiftLocalDataSource {
  final DatabaseService databaseService;

  WorkShiftLocalDataSourceImpl({required this.databaseService});

  @override
  Future<WorkShiftModel?> getActiveWorkShift() async {
    try {
      final db = await databaseService.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'work_shifts',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'open_date DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return WorkShiftModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error getting active work shift from local DB: $e');
    }
  }

  @override
  Future<WorkShiftModel?> getWorkShiftByRemoteId(int remoteId) async {
    try {
      print('DEBUG LOCAL: Buscando turno por remoteId: $remoteId');
      final db = await databaseService.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'work_shifts',
        where: 'remote_id = ?',
        whereArgs: [remoteId],
        limit: 1,
      );

      if (maps.isEmpty) {
        print('DEBUG LOCAL: No se encontró turno con remoteId: $remoteId');
        return null;
      }

      print('DEBUG LOCAL: Turno encontrado: ${maps.first}');
      return WorkShiftModel.fromMap(maps.first);
    } catch (e) {
      print('DEBUG LOCAL: Error buscando turno por remoteId: $e');
      throw Exception('Error getting work shift by remote ID from local DB: $e');
    }
  }

  @override
  Future<int> insertWorkShift(WorkShiftModel workShift) async {
    try {
      final db = await databaseService.database;

      final id = await db.insert(
        'work_shifts',
        workShift.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return id;
    } catch (e) {
      throw Exception('Error inserting work shift to local DB: $e');
    }
  }

  @override
  Future<void> updateWorkShift(WorkShiftModel workShift) async {
    try {
      final db = await databaseService.database;

      await db.update(
        'work_shifts',
        workShift.toMap(),
        where: 'id = ?',
        whereArgs: [workShift.localId],
      );
    } catch (e) {
      throw Exception('Error updating work shift in local DB: $e');
    }
  }

  @override
  Future<void> closeWorkShift(int localId) async {
    try {
      print('DEBUG LOCAL: Cerrando turno con localId: $localId');
      final db = await databaseService.database;

      final closeDate = DateTime.now().toIso8601String();
      print('DEBUG LOCAL: closeDate: $closeDate');
      
      final result = await db.update(
        'work_shifts',
        {
          'close_date': closeDate,
          'is_active': 0,
        },
        where: 'id = ?',
        whereArgs: [localId],
      );
      
      print('DEBUG LOCAL: Filas actualizadas: $result');
      
      if (result == 0) {
        print('DEBUG LOCAL: ADVERTENCIA - No se actualizó ninguna fila');
      }
    } catch (e) {
      print('DEBUG LOCAL: Error al cerrar turno: $e');
      throw Exception('Error closing work shift in local DB: $e');
    }
  }

  @override
  Future<List<WorkShiftModel>> getAllWorkShifts() async {
    try {
      final db = await databaseService.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'work_shifts',
        orderBy: 'open_date DESC',
      );

      return List.generate(
        maps.length,
        (i) => WorkShiftModel.fromMap(maps[i]),
      );
    } catch (e) {
      throw Exception('Error getting all work shifts from local DB: $e');
    }
  }
}


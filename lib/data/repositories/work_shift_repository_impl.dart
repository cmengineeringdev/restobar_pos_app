import '../../domain/entities/work_shift.dart';
import '../../domain/repositories/work_shift_repository.dart';
import '../datasources/local/work_shift_local_datasource.dart';
import '../datasources/remote/work_shift_remote_datasource.dart';
import '../models/work_shift_model.dart';

class WorkShiftRepositoryImpl implements WorkShiftRepository {
  final WorkShiftRemoteDataSource remoteDataSource;
  final WorkShiftLocalDataSource localDataSource;

  WorkShiftRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<WorkShift?> getActiveWorkShiftRemote(int pointOfSaleId) async {
    try {
      print('DEBUG REPO: getActiveWorkShiftRemote - pointOfSaleId: $pointOfSaleId');
      final remoteWorkShift =
          await remoteDataSource.getActiveWorkShift(pointOfSaleId);
      
      if (remoteWorkShift == null) {
        print('DEBUG REPO: No hay turno activo en remoto');
        return null;
      }
      
      print('DEBUG REPO: Turno activo remoto encontrado: remoteId=${remoteWorkShift.remoteId}');
      
      // Buscar si existe en la base de datos local por remoteId
      var localWorkShift = await localDataSource.getWorkShiftByRemoteId(
        remoteWorkShift.remoteId!,
      );
      
      int localId;
      if (localWorkShift == null) {
        // Si no existe en local, crearlo
        print('DEBUG REPO: No existe en local, creándolo...');
        localId = await localDataSource.insertWorkShift(remoteWorkShift);
        print('DEBUG REPO: Turno creado en local con localId: $localId');
      } else {
        // Si existe, usar su localId
        localId = localWorkShift.localId!;
        print('DEBUG REPO: Ya existe en local con localId: $localId');
      }
      
      // Retornar la entidad con ambos IDs
      return WorkShift(
        localId: localId,
        remoteId: remoteWorkShift.remoteId,
        openDate: remoteWorkShift.openDate,
        closeDate: remoteWorkShift.closeDate,
        companyId: remoteWorkShift.companyId,
        pointOfSaleId: remoteWorkShift.pointOfSaleId,
        userId: remoteWorkShift.userId,
        isActive: remoteWorkShift.isActive,
      );
    } catch (e) {
      print('DEBUG REPO: Error en getActiveWorkShiftRemote: $e');
      throw Exception('Error getting active work shift from remote: $e');
    }
  }

  @override
  Future<WorkShift?> getActiveWorkShiftLocal() async {
    try {
      final workShiftModel = await localDataSource.getActiveWorkShift();
      return workShiftModel?.toEntity();
    } catch (e) {
      throw Exception('Error getting active work shift from local: $e');
    }
  }

  @override
  Future<WorkShift> openWorkShift(int pointOfSaleId, String? userId) async {
    try {
      // 1. Primero intentar abrir el turno en remoto
      final remoteWorkShift =
          await remoteDataSource.openWorkShift(pointOfSaleId);

      // 2. Si es exitoso, guardar en la base de datos local
      // Usar el companyId que devuelve el servidor
      final localWorkShift = WorkShiftModel(
        remoteId: remoteWorkShift.remoteId,
        openDate: remoteWorkShift.openDate,
        closeDate: remoteWorkShift.closeDate,
        companyId: remoteWorkShift.companyId,
        pointOfSaleId: pointOfSaleId,
        userId: userId,
        isActive: true,
      );

      final localId = await localDataSource.insertWorkShift(localWorkShift);

      // 3. Retornar el turno completo con ambos IDs
      return WorkShift(
        localId: localId,
        remoteId: remoteWorkShift.remoteId,
        openDate: remoteWorkShift.openDate,
        closeDate: remoteWorkShift.closeDate,
        companyId: remoteWorkShift.companyId,
        pointOfSaleId: pointOfSaleId,
        userId: userId,
        isActive: true,
      );
    } catch (e) {
      throw Exception('Error opening work shift: $e');
    }
  }

  @override
  Future<WorkShift> closeWorkShift(int remoteId, int localId, int pointOfSaleId) async {
    try {
      print('DEBUG REPO: closeWorkShift - remoteId: $remoteId, localId: $localId, pointOfSaleId: $pointOfSaleId');
      
      // 1. Primero cerrar el turno en remoto
      print('DEBUG REPO: Llamando a remoteDataSource.closeWorkShift');
      final closedRemoteWorkShift =
          await remoteDataSource.closeWorkShift(remoteId, pointOfSaleId);
      print('DEBUG REPO: Respuesta remota recibida: $closedRemoteWorkShift');

      // 2. Si es exitoso, actualizar en la base de datos local
      print('DEBUG REPO: Llamando a localDataSource.closeWorkShift');
      await localDataSource.closeWorkShift(localId);
      print('DEBUG REPO: Base de datos local actualizada');

      // 3. Retornar el turno cerrado
      final workShift = WorkShift(
        localId: localId,
        remoteId: closedRemoteWorkShift.remoteId,
        openDate: closedRemoteWorkShift.openDate,
        closeDate: closedRemoteWorkShift.closeDate,
        companyId: closedRemoteWorkShift.companyId,
        pointOfSaleId: pointOfSaleId,
        isActive: false,
      );
      print('DEBUG REPO: Retornando workShift: $workShift');
      return workShift;
    } catch (e) {
      print('DEBUG REPO: Error en closeWorkShift: $e');
      throw Exception('Error closing work shift: $e');
    }
  }

  @override
  Future<List<WorkShift>> getAllWorkShiftsLocal() async {
    try {
      final workShiftModels = await localDataSource.getAllWorkShifts();
      return workShiftModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error getting all work shifts from local: $e');
    }
  }
}


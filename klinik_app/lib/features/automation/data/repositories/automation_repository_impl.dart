import 'dart:developer';
import '../../domain/entities/automation_request.dart';
import '../../domain/repositories/automation_repository.dart';
import '../datasources/automation_remote_data_source.dart';

class AutomationRepositoryImpl implements AutomationRepository {
  final AutomationRemoteDataSource remoteDataSource;

  AutomationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> sendPromptToAutomation(AutomationRequest request) async {
    try {
      return await remoteDataSource.sendPrompt(request);
    } catch (e) {
      log('AutomationRepositoryImpl Error: $e');
      return false;
    }
  }
}

import '../entities/automation_request.dart';
import '../repositories/automation_repository.dart';

class SendAiPromptUseCase {
  final AutomationRepository repository;

  SendAiPromptUseCase(this.repository);

  Future<bool> execute(AutomationRequest request) async {
    // Di sini bisa ditambahkan validasi bisnis sebelum memanggil repository
    if (request.namaPasien.isEmpty || request.keluhan.isEmpty) {
      return false;
    }
    return await repository.sendPromptToAutomation(request);
  }
}

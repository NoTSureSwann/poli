import '../entities/automation_request.dart';

abstract class AutomationRepository {
  Future<bool> sendPromptToAutomation(AutomationRequest request);
}

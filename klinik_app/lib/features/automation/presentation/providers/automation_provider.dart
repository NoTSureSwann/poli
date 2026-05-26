import 'package:flutter/foundation.dart';
import '../../domain/entities/automation_request.dart';
import '../../domain/usecases/send_ai_prompt_usecase.dart';

class AutomationProvider extends ChangeNotifier {
  final SendAiPromptUseCase sendAiPromptUseCase;

  AutomationProvider({required this.sendAiPromptUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> sendPrompt({
    required String namaPasien,
    required String keluhan,
    required String catatanDokter,
  }) async {
    _isLoading = true;
    notifyListeners();

    final request = AutomationRequest(
      namaPasien: namaPasien,
      keluhan: keluhan,
      catatanDokter: catatanDokter,
    );

    final result = await sendAiPromptUseCase.execute(request);

    _isLoading = false;
    notifyListeners();

    return result;
  }
}

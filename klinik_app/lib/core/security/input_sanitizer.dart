class InputSanitizer {
  /// Sanitize user input to prevent basic XSS and Prompt Injections.
  /// Used primarily for sending data to Groq AI.
  static String sanitizeForAi(String input) {
    if (input.isEmpty) return '';

    // Remove control characters (prevent prompt escapes)
    String sanitized = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Limit maximum length to prevent token abuse (DDoS)
    const int maxPromptLength = 500;
    if (sanitized.length > maxPromptLength) {
      sanitized = sanitized.substring(0, maxPromptLength);
    }

    // Escape basic markdown/system keywords if necessary
    // Here we can filter specific trigger words if needed, e.g. "Ignore previous instructions"
    final blockList = [
      'ignore all previous instructions',
      'system prompt',
      'you are no longer',
      'bypass',
    ];

    for (final word in blockList) {
      if (sanitized.toLowerCase().contains(word)) {
        sanitized = sanitized.replaceAll(RegExp(word, caseSensitive: false), '[REDACTED]');
      }
    }

    return sanitized;
  }

  /// Sanitize for basic SQLi / Database writing (though Firestore handles this natively, useful for Supabase RAW SQL)
  static String sanitizeForDb(String input) {
    if (input.isEmpty) return '';
    
    // Replace single quotes to prevent SQLi in raw queries
    String sanitized = input.replaceAll("'", "''");
    
    // Remove HTML tags to prevent XSS on rendering
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    
    return sanitized.trim();
  }

  /// Validate Email with Regex
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate Password: min 8 chars, 1 uppercase, 1 number
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    return hasUppercase && hasDigits;
  }

  /// Strip dangerous characters like <, >, &, ', "
  static String stripDangerousChars(String input) {
    return input.replaceAll(RegExp(r'[<>&'"'"'"]'), '').trim();
  }
}

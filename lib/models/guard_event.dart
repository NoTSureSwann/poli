class GuardEventModel {
  final String ruleId;
  final String action;
  final String context;
  final String triggeredBy;
  final DateTime timestamp;

  GuardEventModel({
    required this.ruleId,
    required this.action,
    required this.context,
    required this.triggeredBy,
    required this.timestamp,
  });

  factory GuardEventModel.fromJson(Map<String, dynamic> json) {
    return GuardEventModel(
      ruleId: json['rule_id'] as String,
      action: json['action'] as String,
      context: json['context'] as String,
      triggeredBy: json['triggered_by'] as String,
      timestamp: json['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rule_id': ruleId,
      'action': action,
      'context': context,
      'triggered_by': triggeredBy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isBlocked => action == 'BLOCKED';
  bool get isAllowed => action == 'ALLOWED';
  bool get isFlagged => action == 'FLAGGED';
}

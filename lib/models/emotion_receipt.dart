class EmotionReceipt {
  EmotionReceipt({
    required this.id,
    required this.createdAtIso,
    required this.persona,
    required this.emotionTemperature,
    required this.emotionSummary,
    required this.mockAiMessage,
  });

  final String id;
  final String createdAtIso;
  final String persona;
  final double emotionTemperature;
  /// 사용자 글을 바탕으로 한 한 줄 감정 요약 (Gemini 생성).
  final String emotionSummary;
  final String mockAiMessage;

  DateTime get createdAt => DateTime.parse(createdAtIso);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'createdAtIso': createdAtIso,
      'persona': persona,
      'emotionTemperature': emotionTemperature,
      'emotionSummary': emotionSummary,
      'mockAiMessage': mockAiMessage,
    };
  }

  factory EmotionReceipt.fromJson(Map<String, dynamic> json) {
    return EmotionReceipt(
      id: json['id'] as String,
      createdAtIso: json['createdAtIso'] as String,
      persona: json['persona'] as String,
      emotionTemperature: (json['emotionTemperature'] as num).toDouble(),
      emotionSummary: json['emotionSummary'] as String? ?? '',
      mockAiMessage: json['mockAiMessage'] as String,
    );
  }
}

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Edge Function이 반환하는 위로 응답 + 감정 한 줄 요약 + 감정 온도.
class GeminiComfortResult {
  const GeminiComfortResult({
    required this.emotionSummary,
    required this.comfortMessage,
    required this.emotionTemperature,
  });

  final String emotionSummary;
  final String comfortMessage;
  final double emotionTemperature;
}

/// Supabase Edge Function(`chat-gemini`) 호출 전담.
class GeminiService {
  Future<GeminiComfortResult> generateComfortWithSummary({
    required String persona,
    required String userText,
  }) async {
    late final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      throw StateError(
          'Supabase가 초기화되지 않았습니다. main()에서 Supabase.initialize를 호출하세요.');
    }

    try {
      final FunctionResponse response = await client.functions.invoke(
        'chat-gemini',
        body: <String, dynamic>{
          'message': userText,
          'systemInstruction': _systemInstructionFor(persona),
        },
      );

      final dynamic rawData = response.data;
      Map<String, dynamic> data;

      if (rawData is Map) {
        data = Map<String, dynamic>.from(rawData);
      } else if (rawData is String) {
        // 혹시라도 String으로 왔을 경우를 대비
        try {
          data = Map<String, dynamic>.from(jsonDecode(rawData));
        } catch (_) {
          throw StateError('서버 응답을 분석할 수 없습니다: $rawData');
        }
      } else {
        throw StateError('알 수 없는 서버 응답 형식: ${rawData.runtimeType}');
      }

      // 지표 추출 (기본값 설정)
      final int arousal = int.tryParse(data['arousal']?.toString() ?? '') ?? 50;
      final int valence = int.tryParse(data['valence']?.toString() ?? '') ?? 50;
      final int complexity =
          int.tryParse(data['complexity']?.toString() ?? '') ?? 30;

      // 여러 가지 가능성 있는 키들을 모두 체크 (Back-end 변동 대응)
      final String summary =
          (data['emotion_summary'] ?? data['summary'] ?? '').toString().trim();
      final String reply =
          (data['comfort_message'] ?? data['reply'] ?? data['text'] ?? '')
              .toString()
              .trim();

      // [다차원 감정 온도 계산 로직]
      double baseTemp = 36.5;
      // 각성도(arousal)가 높을수록 온도가 크게 올라감 (최대 +100도)
      double arousalEffect = (arousal / 100.0) * 100;
      // 부정적인 감정(valence가 0에 가까울수록)이 심할 때, 각성도가 낮으면 온도가 훅 떨어짐 (최대 -30도)
      double depressionEffect =
          ((100 - valence) / 100.0) * ((100 - arousal) / 100.0) * 30;
      // 복잡도(complexity)는 감정의 진폭을 10% 정도 증폭시키는 역할
      double complexityMultiplier = 1.0 + (complexity / 100.0) * 0.1;

      // 최종 온도 계산 (분노/흥분은 더하고, 우울/무기력은 뺌)
      double finalTemp =
          (baseTemp + arousalEffect - depressionEffect) * complexityMultiplier;

      // -30도에서 100도 사이로 클램핑하고 소수점 첫째 자리까지 남김
      finalTemp = finalTemp.clamp(-30.0, 100.0);
      finalTemp = double.parse(finalTemp.toStringAsFixed(1));

      if (reply.isEmpty) {
        throw StateError('위로 메시지가 비어 있습니다. (데이터: $data)');
      }

      return GeminiComfortResult(
        emotionSummary: summary.isNotEmpty ? summary : _localSummary(userText),
        comfortMessage: reply,
        emotionTemperature: finalTemp,
      );
    } on FunctionException catch (e) {
      throw StateError(
        '서버 함수 호출 실패(${e.status}): ${e.reasonPhrase ?? ''}${e.reasonPhrase == null ? '' : ' · '}${e.details}',
      );
    } catch (e) {
      if (e is StateError) rethrow;
      throw StateError('서버 호출 실패: $e');
    }
  }

  String _localSummary(String userText) {
    final String t = userText.trim().replaceAll(RegExp(r'\\s+'), ' ');
    if (t.isEmpty) {
      return '감정 기록';
    }
    const int limit = 25;
    if (t.runes.length <= limit) {
      return t;
    }
    final String clipped = String.fromCharCodes(t.runes.take(limit));
    return '$clipped…';
  }

  String _systemInstructionFor(String persona) {
    const String common = '''
공통 규칙:
- 반드시 한국어로만 답한다.
- 사용자의 문장을 길게 반복하지 않는다.
- 과장된 치유 약속이나 의학·법률 조언은 하지 않는다.
- 공감과 함께 구체적이되 부담 없는 톤을 유지한다.
''';

    switch (persona) {
      case 'rage':
        return '''
당신은 사용자의 분노를 '함께 분출'하는 역할의 친구다.
- 사용자의 감정을 정당화하고, 같이 화내도 된다는 태도로 짧고 힘 있게 호응한다.
- 차분해지라고 재촉하지 않는다. 대신 "그럴 만해", "나도 빡쳐" 같은 동행 톤을 쓴다.
- 마지막에 아주 작은 다음 행동(물 한 모금, 창문 열기 등) 한 가지를 제안할 수 있다(강요 금지).
$common
''';
      case 'advice':
        return '''
당신은 현실적인 조언자다. 감정을 부정하지 않되, 오늘 당장 할 수 있는 행동 위주로 답한다.
- 공감 1~2문장 후, 짧은 실행 제안 2~3가지를 제시한다.
- "반드시", "무조건" 같은 단정은 피하고, 선택지 느낌으로 부드럽게 말한다.
- 문제의 원인을 단정 짓지 말고, 사용자가 통제 가능한 것에 초점을 맞춘다.
$common
''';
      case 'warm':
      default:
        return '''
당신은 따뜻한 위로를 건네는 존재다. 부드럽고 천천히, 판단하지 않는다.
- 사용자의 노력과 버팀을 인정하는 문장으로 시작한다.
- "괜찮아질 거야" 같은 공허한 단정 대신, 지금 이 순간의 감정이 자연스럽다는 톤을 쓴다.
- 마지막은 가벼운 응원 한 줄로 마무리한다.
$common
''';
    }
  }
}

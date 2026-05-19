import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/emotion_receipt.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../widgets/burnit_palette.dart';
import '../widgets/persona_selector.dart';

class BurnScreen extends StatefulWidget {
  const BurnScreen({
    required this.storageService,
    required this.geminiService,
    super.key,
  });

  final StorageService storageService;
  final GeminiService geminiService;

  @override
  State<BurnScreen> createState() => _BurnScreenState();
}

class _BurnScreenState extends State<BurnScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selectedPersona = 'warm';
  bool _aiLoading = false;
  bool _isBurning = false;
  double _textY = 0;
  double _opacity = 1;
  String? _latestReceiptMessage;
  bool _showResultOverlay = false;

  // 🔥 불꽃 애니메이션을 시작하기 위한 트리거 변수 추가
  int _sparkTrigger = 0;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _burnText() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _aiLoading || _isBurning) {
      HapticFeedback.selectionClick();
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _aiLoading = true;
    });

    late final GeminiComfortResult comfort;
    try {
      comfort = await widget.geminiService.generateComfortWithSummary(
        persona: _selectedPersona,
        userText: text,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _aiLoading = false;
      _isBurning = true;
      _showResultOverlay = false;
      _opacity = 0;
      _textY = -70;
      _sparkTrigger++; // 🔥 애니메이션 시작 신호 보내기
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));
    HapticFeedback.heavyImpact();

    final EmotionReceipt receipt = EmotionReceipt(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAtIso: DateTime.now().toIso8601String(),
      persona: _selectedPersona,
      emotionTemperature: comfort.emotionTemperature,
      emotionSummary: comfort.emotionSummary,
      mockAiMessage: comfort.comfortMessage,
    );
    await widget.storageService.saveReceipt(receipt);

    _controller.clear();

    if (!mounted) return;

    // 불꽃 애니메이션이 끝날 때까지 조금 더 대기 (900ms 중 남은 시간)
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _latestReceiptMessage = _personaPrefix(
        _selectedPersona,
        receipt.emotionTemperature,
        receipt.emotionSummary,
        receipt.mockAiMessage,
      );
      _showResultOverlay = true;
      _isBurning = false;
      _opacity = 1;
      _textY = 0;
    });
  }

  void _resetState() {
    _controller.clear();
    _selectedPersona = 'warm';
    _aiLoading = false;
    _isBurning = false;
    _textY = 0;
    _opacity = 1;
    _latestReceiptMessage = null;
    _showResultOverlay = false;
  }

  void _closeResultAndExit() {
    HapticFeedback.lightImpact();
    _resetState();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _personaPrefix(
      String persona, double temperature, String emotionSummary, String msg) {
    // 온도에 따른 상태 힌트 및 이모지 설정
    String tempStatus = '';
    if (temperature >= 85) {
      tempStatus = ' [폭발 직전!]';
    } else if (temperature >= 70) {
      tempStatus = ' [매우 뜨거움]';
    } else if (temperature < 0) {
      tempStatus = ' [꽁꽁 얼어붙음]';
    } else if (temperature < 20) {
      tempStatus = ' [차가운 무기력]';
    }

    final String label = switch (persona) {
      'rage' => '🔥 같이 화내기',
      'advice' => '💧 현실적 조언',
      _ => '🪵 따뜻한 위로',
    };
    final String summaryLine =
        emotionSummary.isNotEmpty ? '지금의 감정: $emotionSummary\n\n' : '';

    // 온도를 소수점 1자리까지 표시
    final String formattedTemp = temperature.toStringAsFixed(1);

    return '$label · 온도 $formattedTemp°C$tempStatus\n$summaryLine$msg';
  }

  @override
  Widget build(BuildContext context) {
    final bool busy = _aiLoading || _isBurning;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          '감정 소각장',
          style: TextStyle(
            color: BurnitPalette.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 18,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                '지금 마음을 편하게 적어주세요.',
                                style: TextStyle(
                                  color: BurnitPalette.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  shadows: <Shadow>[
                                    Shadow(
                                      color: Color(0x338F9BFF),
                                      blurRadius: 10,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                  opacity: _opacity,
                                  child: TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                    tween: Tween<double>(begin: 0, end: _textY),
                                    builder: (_, double value, Widget? child) {
                                      return Transform.translate(
                                        offset: Offset(0, value),
                                        child: child,
                                      );
                                    },
                                    child: TextField(
                                      focusNode: _focusNode,
                                      controller: _controller,
                                      maxLines: null,
                                      expands: true,
                                      readOnly: busy,
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
                                      style: const TextStyle(
                                        color: BurnitPalette.ink,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        height: 1.45,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isCollapsed: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // 🔥 입력창 위에 불꽃 애니메이션 위젯 배치
                          Positioned.fill(
                            child: IgnorePointer(
                              child: _BurnSparks(
                                trigger: _sparkTrigger,
                                active: _isBurning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ... (기존 하단 버튼 코드들과 동일)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '페르소나 선택',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: BurnitPalette.primarySoft,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AbsorbPointer(
                    absorbing: busy,
                    child: Opacity(
                      opacity: busy ? 0.55 : 1,
                      child: PersonaSelector(
                        selectedPersona: _selectedPersona,
                        onSelected: (String value) {
                          setState(() {
                            _selectedPersona = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      onPressed: busy ? null : _burnText,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BurnitPalette.ink,
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                            color: BurnitPalette.outline, width: 1.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ).copyWith(
                        overlayColor: WidgetStatePropertyAll(
                          BurnitPalette.primary.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        _aiLoading
                            ? 'AI 응답 대기 중...'
                            : _isBurning
                                ? '소각 중...'
                                : '소각하기',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 로딩 및 결과 오버레이 (기존과 동일)
          if (_aiLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: const Color(0xCCFFFFFF),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: BurnitPalette.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'AI가 당신의 감정을 읽는 중...',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: BurnitPalette.ink,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '잠시만 기다려 주세요',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: BurnitPalette.inkSubtle,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_showResultOverlay &&
              (_latestReceiptMessage?.isNotEmpty ?? false))
            Positioned.fill(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _closeResultAndExit,
                      child: const ColoredBox(color: Color(0x66000000)),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Builder(
                        builder: (BuildContext context) {
                          final double maxPanel =
                              MediaQuery.sizeOf(context).height * 0.72;
                          const double buttonArea = 88;
                          return Material(
                            color: Colors.white,
                            elevation: 12,
                            shadowColor: Colors.black26,
                            borderRadius: BorderRadius.circular(24),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 400,
                                maxHeight: maxPanel,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: maxPanel - buttonArea,
                                    ),
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(
                                          22, 22, 22, 12),
                                      child: Text(
                                        _latestReceiptMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF333333),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 20),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: _closeResultAndExit,
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFF7A9A8),
                                          foregroundColor:
                                              const Color(0xFF333333),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: const Text(
                                          '닫기',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BurnSparks extends StatefulWidget {
  const _BurnSparks({
    required this.trigger,
    required this.active,
  });

  final int trigger;
  final bool active;

  @override
  State<_BurnSparks> createState() => _BurnSparksState();
}

class _BurnSparksState extends State<_BurnSparks>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(covariant _BurnSparks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _SparkPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) {
      return;
    }

    final Paint paint = Paint()..style = PaintingStyle.fill;
    const List<Color> colors = <Color>[
      Color(0xFFFF6B6B), // 더 강렬한 붉은색
      Color(0xFFF7A9A8), // 핑크빛 불꽃
      Color(0xFFFFB067), // 주황빛 불꽃
    ];

    // 시작 높이를 조금 더 아래로(중앙) 내림
    final double baseY = size.height * (0.65 - progress * 0.6);

    for (int i = 0; i < 25; i++) {
      // 입자 개수 증가 (18 -> 25)
      final double spread = (i - 12) * 0.08; // 퍼지는 범위 증가
      final double x = size.width * (0.5 + spread * (1 - progress * 0.3));
      final double y = baseY - (i % 4) * 15 * progress;

      // 불꽃 크기 증가
      final double radius = (3.0 + (i % 5) * 1.5) * (1 - progress);

      // 투명도를 조금 더 진하게
      paint.color =
          colors[i % colors.length].withValues(alpha: 1.0 - progress * 0.8);
      canvas.drawCircle(Offset(x, y), radius.clamp(0, 6), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

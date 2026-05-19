import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../widgets/burnit_palette.dart';
import '../widgets/flame_illustration.dart';
import 'home_screen.dart';
import 'receipt_list_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.storageService,
    required this.geminiService,
    super.key,
  });

  final StorageService storageService;
  final GeminiService geminiService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: BurnitPalette.welcomeGradient),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double height = constraints.maxHeight;
                final double compact = (height / 760).clamp(0.78, 1.0);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Spacer(),
                          const Text(
                            '감정 소각장',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                      IconButton(
                        tooltip: '감정 영수증 보관함',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ReceiptListScreen(storageService: storageService),
                                ),
                              );
                            },
                        icon: Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                      SizedBox(height: 26 * compact),
                      Text(
                        '무거운 마음,\n잠시 내려놓고 쉬어가세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFFFF3D8),
                          fontSize: 28 * compact,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 18 * compact),
                      Text(
                        '스트레스, 분노, 우울함, 태워버리고 싶은 모든\n감정을 가감 없이 적어주세요. AI가 당신의 편이\n되어 위로해 드립니다:*',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 13 * compact,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: 14 * compact),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 380),
                            child: const FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: 380,
                                child: FlameIllustration(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * compact),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(PageRouteBuilder<void>(
                              pageBuilder: (_, __, ___) => BurnScreen(
                                storageService: storageService,
                                geminiService: geminiService,
                              ),
                              transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 420),
                            ));
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF2F3F7),
                            foregroundColor: BurnitPalette.ink,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: const Text(
                            '소각장 들어가기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

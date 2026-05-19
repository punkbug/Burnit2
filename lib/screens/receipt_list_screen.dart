import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/emotion_receipt.dart';
import '../services/storage_service.dart';
import '../widgets/burnit_palette.dart';

class ReceiptListScreen extends StatefulWidget {
  const ReceiptListScreen({required this.storageService, super.key});

  final StorageService storageService;

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  bool _isLoading = true;
  List<EmotionReceipt> _receipts = <EmotionReceipt>[];

  static const TextStyle _labelStyle = TextStyle(
    color: BurnitPalette.primarySoft,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final List<EmotionReceipt> data = await widget.storageService.loadReceipts();
    if (!mounted) {
      return;
    }
    setState(() {
      _receipts = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteOne(EmotionReceipt receipt) async {
    HapticFeedback.mediumImpact();
    await widget.storageService.deleteReceiptById(receipt.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _receipts = _receipts.where((EmotionReceipt item) => item.id != receipt.id).toList();
    });
  }

  Future<void> _confirmDeleteOne(EmotionReceipt receipt) async {
    HapticFeedback.selectionClick();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('영수증 삭제'),
          content: const Text('이 영수증을 삭제할까요? 삭제하면 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF7A9A8),
                foregroundColor: const Color(0xFF333333),
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteOne(receipt);
    }
  }

  Future<void> _clearAll() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('전체 초기화'),
          content: const Text('모든 영수증을 삭제할까요? 이 작업은 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('전체 삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    HapticFeedback.heavyImpact();
    await widget.storageService.clearAllReceipts();
    if (!mounted) {
      return;
    }
    setState(() {
      _receipts = <EmotionReceipt>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '감정 영수증',
          style: TextStyle(
            color: BurnitPalette.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: _receipts.isEmpty
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      _clearAll();
                    },
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: _receipts.isEmpty ? const Color(0xFFCBD5E1) : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: BurnitPalette.primary),
            )
          : _receipts.isEmpty
          ? const Center(
              child: Text(
                '아직 소각 영수증이 없어요.',
                style: TextStyle(color: BurnitPalette.inkSubtle, fontWeight: FontWeight.w700),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              itemBuilder: (BuildContext context, int index) {
                final EmotionReceipt receipt = _receipts[index];
                return Slidable(
                  key: ValueKey<String>(receipt.id),
                  closeOnScroll: true,
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.34,
                    children: <Widget>[
                      SlidableAction(
                        onPressed: (_) {
                          HapticFeedback.selectionClick();
                          _confirmDeleteOne(receipt);
                        },
                        backgroundColor: const Color(0xFFF7A9A8),
                        foregroundColor: const Color(0xFF333333),
                        icon: Icons.delete_outline_rounded,
                        label: '삭제',
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                        ),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('감정 요약', style: _labelStyle),
                              const SizedBox(height: 8),
                              Text(
                                receipt.emotionSummary.isEmpty ? '감정 기록' : receipt.emotionSummary,
                                style: const TextStyle(
                                  color: BurnitPalette.ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: BurnitPalette.chipUnselectedBg,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _personaLabel(receipt.persona),
                                      style: const TextStyle(
                                        color: BurnitPalette.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F3F7),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '감정 온도 ${receipt.emotionTemperature.toStringAsFixed(1)}°C',
                                      style: const TextStyle(
                                        color: BurnitPalette.inkSubtle,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDate(receipt.createdAt),
                                    style: const TextStyle(
                                      color: BurnitPalette.inkSubtle,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text('AI 메시지', style: _labelStyle),
                              const SizedBox(height: 8),
                              Text(
                                receipt.mockAiMessage,
                                style: const TextStyle(
                                  color: BurnitPalette.ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: IconButton(
                            tooltip: '이 영수증 삭제',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF9CA3AF),
                            ),
                            onPressed: () => _confirmDeleteOne(receipt),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
              itemCount: _receipts.length,
            ),
    );
  }

  String _personaLabel(String persona) {
    switch (persona) {
      case 'rage':
        return '같이 화내기';
      case 'advice':
        return '현실적 조언';
      case 'warm':
      default:
        return '따뜻한 위로';
    }
  }

  String _formatDate(DateTime date) {
    final String mm = date.month.toString().padLeft(2, '0');
    final String dd = date.day.toString().padLeft(2, '0');
    final String hh = date.hour.toString().padLeft(2, '0');
    final String min = date.minute.toString().padLeft(2, '0');
    return '${date.year}.$mm.$dd $hh:$min';
  }
}

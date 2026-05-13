import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/lifetrack_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<LifeTrackProvider>();
      if (p.weeklyInsights.isEmpty && !p.insightsLoading) {
        p.loadWeeklyInsights();
      }
    });
  }

  @override
  void dispose() { _scrollCtrl.dispose(); _inputCtrl.dispose(); super.dispose(); }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    context.read<LifeTrackProvider>().sendChatMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LifeTrackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(children: [
        Expanded(
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            children: [
              Text('AI Insights', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827))),
              const SizedBox(height: 4),
              Text('Habits · Journal · Budget · Powered by Claude',
                  style: TextStyle(fontSize: 12,
                      color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
              const SizedBox(height: 20),

              // Weekly summary card
              _SummaryCard(p: p, isDark: isDark),
              const SizedBox(height: 24),

              Text('ASK ABOUT YOUR LIFE', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8,
                color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
              const SizedBox(height: 12),

              if (p.chatHistory.isEmpty)
                _Suggestions(onTap: (q) { _inputCtrl.text = q; _send(); }),

              ...p.chatHistory.map((m) => _Bubble(message: m, isDark: isDark)),

              if (p.chatLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(children: [
                    Container(width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366f1).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('✨', style: TextStyle(fontSize: 13)))),
                    const SizedBox(width: 8),
                    const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6366f1))),
                  ]),
                ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0f0f0f) : Colors.white,
            border: Border(top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb),
            )),
          ),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _inputCtrl,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Ask about your habits, mood, or budget…',
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF4b5563) : const Color(0xFF9ca3af), fontSize: 14),
                filled: true,
                fillColor: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFF6366f1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final LifeTrackProvider p; final bool isDark;
  const _SummaryCard({required this.p, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('✨', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text('Weekly Summary', style: TextStyle(fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF111827))),
        const Spacer(),
        if (!p.insightsLoading)
          GestureDetector(
            onTap: p.loadWeeklyInsights,
            child: Icon(Icons.refresh_rounded, size: 18,
                color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af)),
          ),
      ]),
      const SizedBox(height: 12),
      if (p.insightsLoading)
        Column(children: [
          const LinearProgressIndicator(backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Color(0xFF6366f1))),
          const SizedBox(height: 8),
          Text('Analysing your week…', style: TextStyle(fontSize: 13,
              color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
        ])
      else if (p.weeklyInsights.isNotEmpty)
        MarkdownBody(data: p.weeklyInsights,
            styleSheet: MarkdownStyleSheet(p: TextStyle(fontSize: 14, height: 1.6,
                color: isDark ? const Color(0xFFd1d5db) : const Color(0xFF374151))))
      else
        Text('Tap refresh to generate your weekly summary.', style: TextStyle(fontSize: 13,
            color: isDark ? const Color(0xFF6b7280) : const Color(0xFF9ca3af))),
    ]),
  );
}

class _Suggestions extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _Suggestions({required this.onTap});

  static const _questions = [
    'How was my week overall?',
    'Am I on track with my habits?',
    'How does my mood relate to my spending?',
    'What should I focus on improving?',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(spacing: 8, runSpacing: 8,
      children: _questions.map((q) => GestureDetector(
        onTap: () => onTap(q),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1a1a2e) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFe5e7eb)),
          ),
          child: Text(q, style: TextStyle(fontSize: 12,
              color: isDark ? const Color(0xFF9ca3af) : const Color(0xFF6b7280))),
        ),
      )).toList(),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Map<String, String> message; final bool isDark;
  const _Bubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = message['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(width: 28, height: 28,
                decoration: BoxDecoration(
                    color: const Color(0xFF6366f1).withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Center(child: Text('✨', style: TextStyle(fontSize: 13)))),
            const SizedBox(width: 8),
          ],
          Flexible(child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF6366f1)
                  : isDark ? const Color(0xFF1e1e2e) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: isUser
                ? Text(message['content'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5))
                : MarkdownBody(data: message['content'] ?? '',
                    styleSheet: MarkdownStyleSheet(p: TextStyle(fontSize: 14, height: 1.6,
                        color: isDark ? const Color(0xFFd1d5db) : const Color(0xFF374151)))),
          )),
        ],
      ),
    );
  }
}

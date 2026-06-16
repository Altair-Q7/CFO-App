// =============================================================================
// AiChatScreen — MADI Financial Intelligence Chat
// =============================================================================
// MADI is not a chatbot — it's a Financial Operations Intelligence System.
// Analytical. Direct. Data-driven. Every response contains a number or decision.
// No greetings. No motivational language. Just financial intelligence.
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/madi_logo.dart';
import '../../widgets/madi_presence_indicator.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _mock = MockDataService();
  final List<Map<String, dynamic>> _messages = [];
  List<String> _suggestions = [];
  bool _loading = false;

  /// Sends a user message and gets MADI's analytical response
  void _send() async {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty) return;
    _msgCtrl.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': msg});
      _loading = true;
    });
    _scrollToBottom();
    final result = await _mock.mockChat(msg);
    if (!mounted) return;
    setState(() {
      _messages.add({'role': 'assistant', 'content': result['response']});
      _suggestions = List<String>.from(result['suggestedQuestions']);
      _loading = false;
    });
    _scrollToBottom();
  }

  void _sendSuggestion(String q) {
    _msgCtrl.text = q;
    _send();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor:
            isDark ? AppTheme.navyDeep : AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('MADI AI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppTheme.textOnDark
                  : AppTheme.onSurfaceText(context),
            )),
        actions: [
          const MadiPresenceIndicator(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // MADI header — intelligence layer, not a chat avatar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.navyGradient,
              border: const Border(
                bottom: BorderSide(color: AppTheme.gold, width: 1),
              ),
            ),
            child: Row(
              children: [
                const MadiLogo(size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Financial Operations Intelligence',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Analytical. Direct. Data-driven.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // System status indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Online',
                        style: TextStyle(
                          color: AppTheme.emerald,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.emerald,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.emerald.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chat messages area
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == _messages.length) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessage(_messages[i]);
                    },
                  ),
          ),

          // Contextual suggestion chips
          if (_suggestions.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                itemBuilder: (ctx, i) {
                  final accent = isDark ? AppTheme.gold : AppTheme.navyDeep;
                  return GestureDetector(
                    onTap: () => _sendSuggestion(_suggestions[i]),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _suggestions[i],
                          style: TextStyle(
                            fontSize: 12,
                            color: accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor(context),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ask about your financials...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppTheme.textOnDarkMuted
                            : AppTheme.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.elevatedColor(context),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textOnDark
                          : AppTheme.onSurfaceText(context),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.navyMid : AppTheme.navyDeep,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _loading ? null : _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state — positions MADI as financial intelligence layer
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MadiLogo(size: 72),
            const SizedBox(height: 24),
            Text(
              'MADI Financial Intelligence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textOnDark
                    : AppTheme.onSurfaceText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze your financial data. Understand\nyour runway, burn rate, and growth trends.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.onSurfaceTextSecondary(context),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.gold : AppTheme.navyDeep)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? AppTheme.gold : AppTheme.navyDeep)
                      .withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ANALYTICAL PROMPTS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.onSurfaceTextSecondary(context),
                      )),
                  const SizedBox(height: 12),
                  _promptRow('Burn Rate Analysis',
                      'Analyze current burn rate and project runway at different spend levels'),
                  const SizedBox(height: 10),
                  _promptRow('Revenue Growth Scenarios',
                      'Model 5%, 10%, and 15% monthly growth over 12 months'),
                  const SizedBox(height: 10),
                  _promptRow('Cost Optimization',
                      'Identify top expense categories and reduction opportunities'),
                  const SizedBox(height: 10),
                  _promptRow('Fundraising Readiness',
                      'Evaluate metrics and timing for Series A'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promptRow(String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.gold : AppTheme.navyDeep;
    return GestureDetector(
      onTap: () => _sendSuggestion(title),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.analytics_rounded,
                color: accent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textOnDark
                          : AppTheme.onSurfaceText(context),
                    )),
                const SizedBox(height: 1),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceTextSecondary(context),
                    )),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 16, color: AppTheme.onSurfaceTextSecondary(context)),
        ],
      ),
    );
  }

  /// Renders a chat bubble — user messages are navy, MADI messages use surface
  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // MADI identity label on assistant messages
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MadiLogo(size: 14),
                  const SizedBox(width: 4),
                  Text('MADI \u00B7 Analysis',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gold,
                      )),
                ],
              ),
            ),
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: isDark
                            ? [AppTheme.navyMid, AppTheme.navyDeep]
                            : [AppTheme.navyDeep, AppTheme.navyLight],
                      )
                    : null,
                color: isUser ? null : AppTheme.surfaceColor(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight:
                      isUser ? Radius.zero : const Radius.circular(16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: AppTheme.borderColor(context)),
                boxShadow: [
                  if (!isUser)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                msg['content'],
                style: TextStyle(
                  color:
                      isUser ? Colors.white : AppTheme.onSurfaceText(context),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Animated typing indicator with MADI-gold dots
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _typingDot(0),
            const SizedBox(width: 4),
            _typingDot(300),
            const SizedBox(width: 4),
            _typingDot(600),
          ],
        ),
      ),
    );
  }

  Widget _typingDot(int delay) {
    return SizedBox(
      width: 8,
      height: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.gold.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

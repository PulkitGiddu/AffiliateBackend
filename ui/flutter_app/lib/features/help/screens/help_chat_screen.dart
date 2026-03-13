import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// In-app help chatbot. Available under Profile.
/// Uses local keyword-based replies (no backend). Theme-aware.
class HelpChatScreen extends StatefulWidget {
  const HelpChatScreen({super.key});

  @override
  State<HelpChatScreen> createState() => _HelpChatScreenState();
}

class _ChatMessage {
  final bool isUser;
  final String text;

  const _ChatMessage({required this.isUser, required this.text});
}

class _HelpChatScreenState extends State<HelpChatScreen> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const String _welcomeText =
      "Hi! I'm here to help with SnatchMart. Ask about wishlist, budgets, deals, coupons, or your account. Type a question or tap a suggestion below.";

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(isUser: false, text: _welcomeText));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getReply(String userText) {
    final lower = userText.trim().toLowerCase();
    if (lower.isEmpty) return "Type a question and I'll try to help!";

    if (RegExp(r'refund|cancel|return|order').hasMatch(lower)) {
      return "Refunds and order issues are handled by the store where you made the purchase. Use the merchant's contact or support page from the deal link. We can help you find the deal again from your Wishlist or order history.";
    }
    if (RegExp(r'account|profile|login|sign|password').hasMatch(lower)) {
      return "Go to Profile → Manage your account to update your name and profile picture. To change password or email, use the sign-in provider you used (e.g. Google). Sign out is at the bottom of the Profile tab.";
    }
    if (RegExp(r'wishlist|save|saved').hasMatch(lower)) {
      return "Your wishlist is under Profile → Wishlist. You can add products from the home screen or product detail. Tap the heart icon on a product to save it.";
    }
    if (RegExp(r'budget|spending|limit|alert').hasMatch(lower)) {
      return "Budget alerts are in Profile → Budget alerts. Set spending limits and get reminders so you stay on track.";
    }
    if (RegExp(r'coupon|code|discount').hasMatch(lower)) {
      return "Coupons are in the Coupons tab. Apply codes at checkout on the merchant's site when you open a deal from SnatchMart.";
    }
    if (RegExp(r'notification|remind|alert').hasMatch(lower)) {
      return "Notifications are in the Notifications tab. You can manage reminders and deal alerts there. Enable them in your device settings if you don't see any.";
    }
    if (RegExp(r'deal|product|price|affiliate').hasMatch(lower)) {
      return "Deals and product links are from our partners. Tap 'Open deal' on a product to go to the store. We may earn a small commission when you buy—this doesn't change the price you pay.";
    }
    if (RegExp(r'make link|link|partner|profit').hasMatch(lower)) {
      return "Exclusive partners can create profit links from Profile → Dashboard → Make Link. You need to be logged in. Check the Dashboard for partner info and profit rates.";
    }
    if (RegExp(r'help|support|contact|faq').hasMatch(lower)) {
      return "You're in the right place! Ask about: wishlist, budgets, coupons, notifications, account, or deals. For direct support, use the feedback option in the app or contact the email shown in the app's About or legal section.";
    }
    if (RegExp(r'hi|hello|hey').hasMatch(lower) && lower.length < 10) {
      return "Hello! How can I help you today? Try asking about wishlist, budgets, or deals.";
    }

    return "I'm not sure about that. Try asking about: wishlist, budgets, coupons, your account, or how deals work. You can also rephrase your question.";
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: trimmed));
      _messages.add(_ChatMessage(isUser: false, text: _getReply(trimmed)));
    });
    _scrollToBottom();
  }

  void _onSuggestionTap(String text) {
    _send(text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Help'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _ChatBubble(
                  isUser: msg.isUser,
                  text: msg.text,
                  scheme: scheme,
                  textTheme: textTheme,
                );
              },
            ),
          ),
          // Quick suggestions (only show near start)
          if (_messages.length <= 1) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SuggestionChip(
                    label: 'How does wishlist work?',
                    onTap: () => _onSuggestionTap('How does wishlist work?'),
                    scheme: scheme,
                  ),
                  _SuggestionChip(
                    label: 'Budget alerts',
                    onTap: () => _onSuggestionTap('Budget alerts'),
                    scheme: scheme,
                  ),
                  _SuggestionChip(
                    label: 'How do deals work?',
                    onTap: () => _onSuggestionTap('How do deals work?'),
                    scheme: scheme,
                  ),
                  _SuggestionChip(
                    label: 'Contact support',
                    onTap: () => _onSuggestionTap('Contact support'),
                    scheme: scheme,
                  ),
                ],
              ),
            ),
          ],
          // Input row
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask something...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 2,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _send(_controller.text),
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      minimumSize: const Size(48, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isUser,
    required this.text,
    required this.scheme,
    required this.textTheme,
  });

  final bool isUser;
  final String text;
  final ColorScheme scheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        decoration: BoxDecoration(
          color: isUser
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          text,
          style: textTheme.bodyLarge?.copyWith(
            color: isUser ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: scheme.surfaceContainerHighest,
      side: BorderSide(color: scheme.outlineVariant),
    );
  }
}

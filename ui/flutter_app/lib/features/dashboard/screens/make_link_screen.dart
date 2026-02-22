import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Make your own Profit Links — paste partner link, generate profit link. Login required.
class MakeLinkScreen extends ConsumerStatefulWidget {
  const MakeLinkScreen({super.key});

  @override
  ConsumerState<MakeLinkScreen> createState() => _MakeLinkScreenState();
}

class _MakeLinkScreenState extends ConsumerState<MakeLinkScreen> {
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Make Link'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card: gradient strip (matches app bar / home header)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary,
                      scheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Title: "Make your own Profit Links in Seconds."
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.35,
                        ),
                        children: [
                          const TextSpan(text: 'Make your own '),
                          TextSpan(
                            text: 'Profit Links',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white.withOpacity(0.95),
                              decorationThickness: 2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(text: ' in Seconds.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Paste a link from our active partner sites in the box below to make a link & share it.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // SEE PARTNERS & PROFIT RATES — theme outline style
              OutlinedButton(
                onPressed: () {
                  // TODO: navigate to partners / profit rates
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.primary,
                  side: BorderSide(color: scheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SEE PARTNERS & PROFIT RATES',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Link input card (theme surface + primary accent)
              Material(
                color: scheme.surfaceContainerHighest.withOpacity(isDark ? 0.6 : 0.5),
                borderRadius: BorderRadius.circular(16),
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.primary,
                              scheme.primary.withOpacity(0.85),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.link_rounded,
                          color: scheme.onPrimary,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _linkController,
                          decoration: InputDecoration(
                            hintText: 'Paste homepage or product link here',
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 8,
                            ),
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface,
                          ),
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // MAKE PROFIT LINK — primary CTA
              FilledButton(
                onPressed: () {
                  final link = _linkController.text.trim();
                  if (link.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Paste a link first',
                          style: TextStyle(color: scheme.onInverseSurface),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: scheme.inverseSurface,
                      ),
                    );
                    return;
                  }
                  // TODO: call API to create profit link
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Link submitted: ${link.length} chars',
                        style: TextStyle(color: scheme.onInverseSurface),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: scheme.inverseSurface,
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'MAKE PROFIT LINK',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

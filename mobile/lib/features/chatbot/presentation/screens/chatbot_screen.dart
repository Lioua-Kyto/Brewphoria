import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/constants/app_spacing.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/router/route_names.dart';
import 'package:coffee_card/core/utils/extensions.dart';
import 'package:coffee_card/core/errors/app_exception.dart';
import 'package:coffee_card/core/widgets/auth_gate.dart';
import 'package:coffee_card/core/widgets/brew_snack.dart';
import 'package:coffee_card/core/widgets/product_cutout.dart';
import 'package:coffee_card/core/widgets/pressable.dart';
import 'package:coffee_card/features/chatbot/presentation/providers/chat_provider.dart';
import 'package:coffee_card/features/chatbot/domain/chat_message_model.dart';
import 'package:coffee_card/features/cart/presentation/providers/cart_provider.dart';
import 'package:coffee_card/features/auth/presentation/providers/auth_provider.dart';

const _quickChips = ['☕ Surprise me', 'Low sugar', 'Something iced'];

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _textController.text).trim();
    if (text.isEmpty) return;
    _textController.clear();
    await ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    final isSending = ref.watch(chatNotifierProvider.notifier).isSending;
    final name =
        ref.watch(authNotifierProvider).valueOrNull?.displayName.split(' ').first;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF160F0A)
          : const Color(0xFFF3EBE0),
      body: Stack(
        children: [
          Positioned.fill(
            child: messages.isEmpty
                ? _ChatIntro(name: name, onTap: (s) => _send(s))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(18, topInset + 78, 18, 150),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => _Bubble(message: messages[i]),
                  ),
          ),
          _GlassHeader(topInset: topInset),
          _BottomBar(
            controller: _textController,
            isSending: isSending,
            showChips: messages.isNotEmpty,
            onSend: () => _send(),
            onChip: (c) => _send(c),
          ),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────
class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.topInset});
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.fromLTRB(18, topInset + 8, 18, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xCC160F0A) : const Color(0xCCF3EBE0),
              border: Border(
                  bottom: BorderSide(
                      color: isDark
                          ? AppColors.secondary.withValues(alpha: 0.12)
                          : AppColors.onBackground.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                Pressable(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: isDark
                          ? Border.all(color: AppColors.amberBorderDark)
                          : null,
                      boxShadow: isDark ? null : AppColors.cardShadow,
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Barista',
                              style: GoogleFonts.fraunces(
                                  fontSize: 19, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 7),
                          Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text('online',
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                        ],
                      ),
                      Text('Your AI order helper',
                          style: AppTextStyles.captionText
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const _BaristaMark(size: 38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Abstract barista mark — a gold steam-cup glyph (no robot, per brief §5.8).
class _BaristaMark extends StatelessWidget {
  const _BaristaMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFE7C173), Color(0xFFB8863C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Icon(Icons.local_cafe_rounded,
          size: size * 0.5, color: Colors.white),
    );
  }
}

// ── Bubbles ──────────────────────────────────────────────────────────────────
class _Bubble extends ConsumerWidget {
  const _Bubble({required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == ChatRole.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(message.content,
                style: GoogleFonts.hankenGrotesk(
                    fontSize: 14.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF241812))),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _BaristaMark(size: 30),
          const SizedBox(width: 9),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.surfaceGlowDark : AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(20),
                    ),
                    border: isDark
                        ? Border.all(color: AppColors.amberBorderDark)
                        : null,
                    boxShadow: isDark ? null : AppColors.cardShadow,
                  ),
                  child: message.isLoading
                      ? const _TypingDots()
                      : Text(message.content,
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 14.5,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurface)),
                ),
                if (message.product != null) ...[
                  const SizedBox(height: 8),
                  _InChatProductCard(product: message.product!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini floating-cutout product card rendered inline in the conversation
/// (design 5.8) — tap to open, or Add straight to cart.
class _InChatProductCard extends ConsumerWidget {
  const _InChatProductCard({required this.product});
  final ChatProductRef product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.pushNamed(RouteNames.productDetail,
          pathParameters: {'slug': product.slug}),
      child: SizedBox(
        width: 230,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 72),
              padding: const EdgeInsets.fromLTRB(66, 12, 14, 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: isDark
                    ? Border.all(color: AppColors.amberBorderDark)
                    : null,
                boxShadow: isDark ? null : AppColors.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fraunces(
                          fontSize: 15, fontWeight: FontWeight.w600, height: 1.1)),
                  if (product.meta != null) ...[
                    const SizedBox(height: 2),
                    Text(product.meta!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.captionText
                            .copyWith(fontSize: 12, color: AppColors.textMuted)),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.price.toCurrency,
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.secondary
                                  : const Color(0xFFB87423))),
                      Pressable(
                        onTap: () async {
                          if (!await requireAccount(context, ref,
                              action: 'add to your cart')) {
                            return;
                          }
                          try {
                            await ref
                                .read(cartNotifierProvider.notifier)
                                .addItem(product.id, 1);
                            if (context.mounted) {
                              showBrewSnack(
                                  context, '${product.name} added to your cart',
                                  icon: Icons.local_cafe_rounded);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showBrewSnack(context, friendlyError(e),
                                  kind: BrewSnackKind.error);
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.primaryDark : AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Add',
                                  style: GoogleFonts.hankenGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.onPrimaryDark
                                          : AppColors.onPrimary)),
                              const SizedBox(width: 3),
                              Icon(Icons.add,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.onPrimaryDark
                                      : AppColors.onPrimary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: -4,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: product.image.isEmpty
                      ? const SizedBox.shrink()
                      : ProductCutout(
                          url: product.image,
                          decodeWidth: 200,
                          shadowOffset: const Offset(0, 8),
                          shadowBlur: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = ((_c.value + i * 0.2) % 1.0);
            final o = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: o),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Bottom bar ───────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.controller,
    required this.isSending,
    required this.showChips,
    required this.onSend,
    required this.onChip,
  });
  final TextEditingController controller;
  final bool isSending;
  final bool showChips;
  final VoidCallback onSend;
  final ValueChanged<String> onChip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showChips)
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                itemCount: _quickChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => Pressable(
                  onTap: () => onChip(_quickChips[i]),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.surfaceDark : AppColors.surface)
                          .withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                          color: isDark
                              ? AppColors.amberBorderDark
                              : AppColors.outline),
                    ),
                    child: Text(_quickChips[i],
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFC9B7A3)
                                : const Color(0xFF5C4A3A))),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                12, 0, 12, MediaQuery.of(context).padding.bottom + 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xD1160F0A)
                        : const Color(0xD1F7F1EA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isDark
                            ? AppColors.secondary.withValues(alpha: 0.22)
                            : const Color(0xB3FFFFFF)),
                    boxShadow: [
                      BoxShadow(
                          color: isDark
                              ? const Color(0x80000000)
                              : const Color(0x333B2417),
                          blurRadius: 30,
                          offset: const Offset(0, 12)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          textInputAction: TextInputAction.send,
                          textAlignVertical: TextAlignVertical.center,
                          onSubmitted: (_) => onSend(),
                          style: GoogleFonts.hankenGrotesk(fontSize: 14.5),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            hintText: 'Ask the barista…',
                            hintStyle: GoogleFonts.hankenGrotesk(
                                fontSize: 14.5, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Pressable(
                        onTap: isSending ? null : onSend,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: isSending
                              ? const Padding(
                                  padding: EdgeInsets.all(11),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFFF0C888)),
                                )
                              : Icon(Icons.arrow_forward_rounded,
                                  size: 19,
                                  color: isDark
                                      ? AppColors.onPrimaryDark
                                      : const Color(0xFFF0C888)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Intro ────────────────────────────────────────────────────────────────────
class _ChatIntro extends StatelessWidget {
  const _ChatIntro({required this.name, required this.onTap});
  final String? name;
  final ValueChanged<String> onTap;

  static const _suggestions = [
    '"Something cozy under \$5"',
    '"Most caffeine you\'ve got"',
    '"A pastry that pairs with cold brew"',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(34, 120, 34, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BaristaMark(size: 88),
            const SizedBox(height: 22),
            Text(
                name != null
                    ? "Hey $name — I'm your barista"
                    : "Hey — I'm your barista",
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                    fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              "Tell me your mood, your budget, or your caffeine goal, and I'll build the perfect order. Try one of these:",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            for (final s in _suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Pressable(
                  onTap: () => onTap(s.replaceAll('"', '')),
                  scale: 0.98,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color:
                          isDark ? AppColors.surfaceGlowDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: isDark
                          ? Border.all(color: AppColors.amberBorderDark)
                          : null,
                      boxShadow: isDark ? null : AppColors.cardShadow,
                    ),
                    child: Text(s,
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

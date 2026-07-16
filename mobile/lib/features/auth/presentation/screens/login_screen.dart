import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/errors/app_exception.dart';
import 'package:brewphoria/core/constants/app_text_styles.dart';
import 'package:brewphoria/core/router/route_names.dart';
import 'package:brewphoria/core/widgets/product_cutout.dart';
import 'package:brewphoria/core/widgets/pressable.dart';
import 'package:brewphoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:brewphoria/features/auth/presentation/providers/guest_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (_isRegister) {
      ref.read(authNotifierProvider.notifier).registerWithEmail(email, password);
    } else {
      ref.read(authNotifierProvider.notifier).signInWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    ref.listen<AsyncValue<dynamic>>(authNotifierProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(next.error!)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    final isLoading = authState.isLoading;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Warm hero well
            Container(
              height: 296,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [Color(0xFFFBF4EA), Color(0xFFEFE3D2), Color(0xFFE7D9C4)],
                  stops: [0, 0.6, 1],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft warm spotlight behind the cup (matches Product Detail).
                  Padding(
                    padding: EdgeInsets.only(top: topInset + 20),
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFFFFBF3),
                            Color(0x80FFFBF3),
                            Color(0x1AFFFBF3),
                            Color(0x00FFFBF3),
                          ],
                          stops: [0.0, 0.45, 0.72, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: topInset + 30),
                    child: const SizedBox(
                      width: 210,
                      height: 230,
                      child: ProductCutout(
                        url: 'assets/img/cappuccino.png',
                        shadowColor: Color(0x473B2417),
                        shadowOffset: Offset(0, 26),
                        shadowBlur: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Rising sheet
            Transform.translate(
              offset: const Offset(0, -32),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x143B2417),
                        blurRadius: 30,
                        offset: Offset(0, -12)),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(26, 20, 26, 34),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.onBackground.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('BrewPhoria', style: AppTextStyles.wordmark(34)),
                    const SizedBox(height: 16),
                    Text('Save your orders, earn every cup.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fraunces(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text('Sign in to keep your Gold cup filling.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 13.5, color: AppColors.textSecondary)),
                    const SizedBox(height: 26),

                    // Google — primary social
                    _SocialButton(
                      onTap: isLoading
                          ? null
                          : () => ref
                              .read(authNotifierProvider.notifier)
                              .signInWithGoogle(),
                      label: 'Continue with Google',
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or use email',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'you@email.com',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 11),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                isLoading ? null : _submitEmail(),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (_isRegister && v.length < 6) {
                                return 'At least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Pressable(
                            onTap: isLoading ? null : _submitEmail,
                            child: Container(
                              height: 54,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Color(0x52D98E32),
                                      blurRadius: 22,
                                      offset: Offset(0, 10)),
                                ],
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF241812)),
                                    )
                                  : Text(
                                      _isRegister
                                          ? 'Create account'
                                          : 'Continue with email',
                                      style: GoogleFonts.hankenGrotesk(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF241812))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Pressable(
                      onTap: () => setState(() => _isRegister = !_isRegister),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text.rich(
                          TextSpan(
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                  text: _isRegister
                                      ? 'Already have an account? '
                                      : 'New to BrewPhoria? '),
                              TextSpan(
                                  text: _isRegister ? 'Sign in' : 'Register',
                                  style: const TextStyle(
                                      color: Color(0xFFB87423),
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: AppTextStyles.captionText
                            .copyWith(color: AppColors.textMuted, height: 1.5),
                        children: const [
                          TextSpan(text: 'By continuing you agree to our '),
                          TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                  color: Color(0xFFB87423),
                                  fontWeight: FontWeight.w600)),
                          TextSpan(text: ' & '),
                          TextSpan(
                              text: 'Privacy',
                              style: TextStyle(
                                  color: Color(0xFFB87423),
                                  fontWeight: FontWeight.w600)),
                          TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Pressable(
                      onTap: () {
                        ref.read(guestModeProvider.notifier).set(true);
                        context.go(RoutePaths.shop);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text('Browse as a guest  →',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.onTap, required this.label});
  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D3B2417),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: Text('G',
                  style: GoogleFonts.fraunces(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
            const SizedBox(width: 11),
            Text(label,
                style: GoogleFonts.hankenGrotesk(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBackground)),
          ],
        ),
      ),
    );
  }
}

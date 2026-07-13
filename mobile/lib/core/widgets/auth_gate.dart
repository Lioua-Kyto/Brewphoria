import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/router/route_names.dart';
import 'package:coffee_card/features/auth/presentation/providers/auth_provider.dart';

/// Returns true if the user has an account. Otherwise shows a warm sign-in
/// prompt sheet (guest browsing) and returns false.
Future<bool> requireAccount(
  BuildContext context,
  WidgetRef ref, {
  String action = 'continue',
}) async {
  final loggedIn = ref.read(authNotifierProvider).valueOrNull != null;
  if (loggedIn) return true;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFE7C173), Color(0xFFB8863C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.local_cafe_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 18),
              Text('Join BrewPhoria',
                  style:
                      GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Sign in to $action, earn points on every cup, and keep your favourites.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ctx.goNamed(RouteNames.login);
                  },
                  child: const Text('Sign in or create account'),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Keep browsing',
                    style: GoogleFonts.hankenGrotesk(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      );
    },
  );
  return false;
}

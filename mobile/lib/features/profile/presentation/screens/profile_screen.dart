import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/errors/app_exception.dart';
import 'package:coffee_card/core/widgets/address_autocomplete_field.dart';
import 'package:coffee_card/core/widgets/brew_snack.dart';
import 'package:coffee_card/core/constants/app_spacing.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/router/app_router.dart';
import 'package:coffee_card/core/router/route_names.dart';
import 'package:coffee_card/core/theme/theme_mode_provider.dart';
import 'package:coffee_card/core/widgets/app_network_image.dart';
import 'package:coffee_card/core/widgets/coffee_cup.dart';
import 'package:coffee_card/core/widgets/product_cutout.dart';
import 'package:coffee_card/core/widgets/pressable.dart';
import 'package:coffee_card/core/utils/extensions.dart';
import 'package:coffee_card/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffee_card/features/profile/presentation/providers/profile_provider.dart';
import 'package:coffee_card/features/profile/domain/profile_model.dart';
import 'package:coffee_card/features/loyalty/presentation/providers/loyalty_provider.dart';
import 'package:coffee_card/features/wishlist/presentation/providers/wishlist_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final loyalty = ref.watch(loyaltyAccountProvider).valueOrNull;
    final favourites = ref.watch(wishlistNotifierProvider).valueOrNull ?? const [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(loyaltyAccountProvider);
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              22, MediaQuery.of(context).padding.top + 14, 22, kGlassNavClearance),
          children: [
            userAsync.when(
              data: (user) => _Identity(
                  name: user.fullName,
                  email: user.email,
                  avatarUrl: user.avatarUrl,
                  tier: loyalty?.tier),
              loading: () => const SizedBox(height: 72),
              error: (e, _) => Text(friendlyError(e)),
            ),
            const SizedBox(height: 22),
            if (loyalty != null)
              _LoyaltyStrip(
                currentPoints: loyalty.currentPoints,
                lifetimePoints: loyalty.lifetimePoints,
                tier: loyalty.tier,
              ),
            if (favourites.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Your favourites',
                  style: GoogleFonts.fraunces(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 158,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: favourites.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final p = favourites[i];
                    return _FavouriteCard(
                      name: p.name,
                      price: p.price.toCurrency,
                      imageUrl: p.images.isNotEmpty ? p.images.first : '',
                      onTap: () => context.pushNamed(RouteNames.productDetail,
                          pathParameters: {'slug': p.slug}),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('Settings',
                style: GoogleFonts.fraunces(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _SettingsCard(children: [
              _SettingsRow(
                icon: Icons.person_outline_rounded,
                label: 'Edit profile',
                onTap: () => _showEditProfile(
                    context, ref, userAsync.valueOrNull?.displayName ?? ''),
              ),
              _SettingsRow(
                icon: Icons.location_on_outlined,
                label: 'Delivery addresses',
                onTap: () => _showAddresses(context, ref),
              ),
              _SettingsRow(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () => context.pushNamed(RouteNames.notifications),
              ),
              _SettingsRow(
                icon: Icons.dark_mode_outlined,
                label: 'Dark mode',
                trailing: _DarkToggle(
                  value: isDark,
                  onChanged: (v) =>
                      ref.read(appThemeModeProvider.notifier).setDark(v),
                ),
              ),
              _SettingsRow(
                icon: Icons.help_outline_rounded,
                label: 'Help & support',
                isLast: true,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support: hello@brewphoria.co')),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Center(
              child: Pressable(
                onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text('Sign out',
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddresses(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddressesBottomSheet(),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(initialName: current),
    );
  }
}

/// Edit the display name; keeps the Shop greeting + profile in sync on save.
class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.initialName});
  final String initialName;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.initialName);
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(profileDataSourceProvider)
          .updateProfile(UpdateProfileRequest(displayName: name));
      ref.read(authNotifierProvider.notifier).setUser(updated);
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      Navigator.pop(context);
      showBrewSnack(context, 'Profile updated', icon: Icons.check_rounded);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showBrewSnack(context, friendlyError(e), kind: BrewSnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit profile',
                  style: GoogleFonts.fraunces(
                      fontSize: 21, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text('Name',
                  style: AppTextStyles.overline
                      .copyWith(fontSize: 10.5, letterSpacing: 1.4)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Your name',
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity(
      {required this.name,
      required this.email,
      this.avatarUrl,
      this.tier});
  final String name;
  final String email;
  final String? avatarUrl;
  final String? tier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFFE7C173), Color(0xFFB8863C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : const LinearGradient(
                    colors: [Color(0xFF4A2E1B), Color(0xFF3B2417)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: (isDark ? AppColors.secondary : AppColors.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? AppNetworkImage(url: avatarUrl!, fit: BoxFit.cover)
              : Text(name.isNotEmpty ? name[0].toUpperCase() : 'B',
                  style: GoogleFonts.fraunces(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF241812)
                          : const Color(0xFFF0C888))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.fraunces(
                      fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(email,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              if (tier != null) ...[
                const SizedBox(height: 7),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: isDark ? 0.16 : 0.14),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.secondary),
                      const SizedBox(width: 5),
                      Text(
                          '${tier![0]}${tier!.substring(1).toLowerCase()} member',
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFB87423))),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LoyaltyStrip extends StatelessWidget {
  const _LoyaltyStrip(
      {required this.currentPoints,
      required this.lifetimePoints,
      required this.tier});
  final int currentPoints;
  final int lifetimePoints;
  final String tier;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (next, _) = _nextTierP(tier);
    final remaining = next == null ? 0 : (next - lifetimePoints);
    final floor = _tierFloorP(tier);
    final fill =
        next == null ? 1.0 : ((lifetimePoints - floor) / (next - floor)).clamp(0.0, 1.0);
    return Pressable(
      onTap: () => context.goNamed(RouteNames.loyalty),
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF3B2417), Color(0xFF4A2E1B)],
                  begin: Alignment(-0.8, -1),
                  end: Alignment(0.8, 1)),
          color: isDark ? AppColors.surfaceGlowDark : null,
          border: isDark
              ? Border.all(color: AppColors.secondary.withValues(alpha: 0.18))
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CoffeeCup(fill: fill, width: 44, height: 60, glow: isDark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Points balance',
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 12, color: const Color(0xFFC9B7A3))),
                  Text('${currentPoints.toPoints} pts',
                      style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF0C888))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Next tier',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 12, color: const Color(0xFFC9B7A3))),
                Text(next == null ? 'Top tier' : '$remaining to go',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onBackgroundDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

int _tierFloorP(String tier) => switch (tier) {
      'SILVER' => 500,
      'GOLD' => 1500,
      'PLATINUM' => 3000,
      _ => 0,
    };
(int?, String?) _nextTierP(String tier) => switch (tier) {
      'BRONZE' => (500, 'Silver'),
      'SILVER' => (1500, 'Gold'),
      'GOLD' => (3000, 'Platinum'),
      _ => (null, null),
    };

class _FavouriteCard extends StatelessWidget {
  const _FavouriteCard(
      {required this.name,
      required this.price,
      required this.imageUrl,
      required this.onTap});
  final String name;
  final String price;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 44, 12, 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: isDark
                      ? Border.all(color: AppColors.amberBorderDark)
                      : null,
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fraunces(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.1)),
                    const SizedBox(height: 5),
                    Text(price,
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB87423))),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 66,
                  height: 66,
                  child: imageUrl.isEmpty
                      ? const SizedBox.shrink()
                      : ProductCutout(
                          url: imageUrl,
                          decodeWidth: 200,
                          shadowOffset: const Offset(0, 10),
                          shadowBlur: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: isDark ? Border.all(color: AppColors.amberBorderDark) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                      color: (isDark ? AppColors.outlineDark : AppColors.outline)
                          .withValues(alpha: 0.6))),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 17, color: const Color(0xFFB87423)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.hankenGrotesk(
                      fontSize: 14.5, fontWeight: FontWeight.w500)),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _DarkToggle extends StatelessWidget {
  const _DarkToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 46,
        height: 27,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.secondary : AppColors.outline,
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 21,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

void _showAddAddressSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _AddAddressSheetProfile(
      onSaved: (data) async {
        await ref.read(addressesNotifierProvider.notifier).addAddress(data);
      },
    ),
  );
}

class _AddressesBottomSheet extends ConsumerWidget {
  const _AddressesBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesNotifierProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text('Delivery Addresses', style: AppTextStyles.headlineSmall),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _showAddAddressSheet(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add New Address'),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: addressesAsync.when(
              data: (addresses) => addresses.isEmpty
                  ? const Center(child: Text('No addresses saved yet.'))
                  : ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.all(16),
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (_, i) => _AddressTile(
                        address: addresses[i],
                        onDelete: () async {
                          await ref
                              .read(addressesNotifierProvider.notifier)
                              .deleteAddress(addresses[i].id);
                        },
                      ),
                    ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(friendlyError(e))),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAddressSheetProfile extends StatefulWidget {
  const _AddAddressSheetProfile({required this.onSaved});
  final Future<void> Function(Map<String, dynamic> data) onSaved;

  @override
  State<_AddAddressSheetProfile> createState() =>
      _AddAddressSheetProfileState();
}

class _AddAddressSheetProfileState extends State<_AddAddressSheetProfile> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController(text: 'Home');
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'US');
  bool _isDefault = true;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _labelCtrl, _nameCtrl, _phoneCtrl, _streetCtrl,
      _cityCtrl, _stateCtrl, _postalCtrl, _countryCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSaved({
        'label': _labelCtrl.text.trim(),
        'fullName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'street': _streetCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'postalCode': _postalCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'isDefault': _isDefault,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(friendlyError(e)),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('Add Address', style: AppTextStyles.headlineSmall),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _ProfileField(label: 'Label', hint: 'e.g. Home, Work', ctrl: _labelCtrl),
              _ProfileField(label: 'Full Name', ctrl: _nameCtrl),
              _ProfileField(label: 'Phone', ctrl: _phoneCtrl, keyboardType: TextInputType.phone),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AddressAutocompleteField(
                  controller: _streetCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Street Address',
                      hintText: 'Start typing to search…'),
                  onSelected: (addr) => setState(() {
                    if (addr.city.isNotEmpty) _cityCtrl.text = addr.city;
                    if (addr.state.isNotEmpty) _stateCtrl.text = addr.state;
                    if (addr.postalCode.isNotEmpty) {
                      _postalCtrl.text = addr.postalCode;
                    }
                    if (addr.country.isNotEmpty) _countryCtrl.text = addr.country;
                  }),
                ),
              ),
              Row(
                children: [
                  Expanded(child: _ProfileField(label: 'City', ctrl: _cityCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _ProfileField(label: 'State', hint: 'e.g. NY', ctrl: _stateCtrl)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _ProfileField(label: 'Postal Code', ctrl: _postalCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _ProfileField(label: 'Country', ctrl: _countryCtrl)),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as default'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.ctrl,
    this.hint,
    this.keyboardType,
  });
  final String label;
  final TextEditingController ctrl;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: (v) =>
            v == null || v.trim().isEmpty ? '$label is required' : null,
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address, required this.onDelete});

  final AddressModel address;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(address.label, style: AppTextStyles.labelLarge),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.statusDelivered.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Default',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.statusDelivered)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(address.fullName, style: AppTextStyles.bodySmall),
              Text(address.phone, style: AppTextStyles.bodySmall),
              Text(
                  '${address.street}, ${address.city}, ${address.state} ${address.postalCode}',
                  style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline,
              color: AppColors.error, size: 20),
        ),
      ],
    );
  }
}

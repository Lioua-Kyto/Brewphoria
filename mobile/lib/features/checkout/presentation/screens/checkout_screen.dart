import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_card/core/constants/app_colors.dart';
import 'package:coffee_card/core/errors/app_exception.dart';
import 'package:coffee_card/core/widgets/address_autocomplete_field.dart';
import 'package:coffee_card/core/constants/app_spacing.dart';
import 'package:coffee_card/core/constants/app_text_styles.dart';
import 'package:coffee_card/core/router/route_names.dart';
import 'package:coffee_card/core/utils/extensions.dart';
import 'package:coffee_card/core/widgets/pressable.dart';
import 'package:coffee_card/features/cart/presentation/providers/cart_provider.dart';
import 'package:coffee_card/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:coffee_card/features/loyalty/presentation/providers/loyalty_provider.dart';
import 'package:coffee_card/features/profile/presentation/providers/profile_provider.dart';
import 'package:coffee_card/features/orders/domain/order_history_model.dart';

const double _freeDeliveryThreshold = 50.0;
const double _deliveryFee = 5.99;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({this.tipAmount = 0, super.key});

  final double tipAmount;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  int _pointsToRedeem = 0;
  String _paymentMethod = 'COD';
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carry over the points the shopper already chose to redeem in the cart.
    _pointsToRedeem = ref.read(checkoutRedeemProvider);
    if (_pointsToRedeem > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(redemptionNotifierProvider.notifier).validate(_pointsToRedeem);
        }
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _showAddAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAddressSheet(
        onSaved: (data) async {
          await ref.read(addressesNotifierProvider.notifier).addAddress(data);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartNotifierProvider);
    final addressesAsync = ref.watch(addressesNotifierProvider);
    final loyaltyAsync = ref.watch(loyaltyAccountProvider);
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final redemptionAsync = ref.watch(redemptionNotifierProvider);

    final cart = cartAsync.valueOrNull;
    final subtotal = cart?.items.fold<double>(
          0,
          (sum, item) => sum + item.effectiveUnitPrice * item.quantity,
        ) ??
        0;
    final delivery = subtotal >= _freeDeliveryThreshold ? 0.0 : _deliveryFee;
    final discount = redemptionAsync.valueOrNull?.discountAmount ?? 0.0;
    final total = subtotal + delivery + widget.tipAmount - discount;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Checkout', style: AppTextStyles.headlineMedium),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 130),
            children: [
              _SectionLabel('Delivery address'),
              addressesAsync.when(
                data: (addresses) {
                  if (addresses.isEmpty) {
                    return _AddAffordance(
                      label: 'Add a delivery address',
                      onTap: _showAddAddressSheet,
                    );
                  }
                  final selectedId = _selectedAddressId ??
                      addresses.where((a) => a.isDefault).firstOrNull?.id ??
                      addresses.first.id;
                  return Column(
                    children: [
                      for (final addr in addresses)
                        _AddressCard(
                          title: '${addr.label} · ${addr.fullName}',
                          subtitle:
                              '${addr.street}, ${addr.city}, ${addr.state}',
                          selected: addr.id == selectedId,
                          onTap: () =>
                              setState(() => _selectedAddressId = addr.id),
                        ),
                      _AddAffordance(
                        label: 'Add another address',
                        onTap: _showAddAddressSheet,
                      ),
                    ],
                  );
                },
                loading: () => const _MiniLoader(),
                error: (e, _) => Text(friendlyError(e)),
              ),
              const SizedBox(height: 22),
              _SectionLabel('Payment method'),
              Row(
                children: [
                  Expanded(
                    child: _PayCard(
                      label: 'Cash on Delivery',
                      icon: Icons.payments_outlined,
                      selected: _paymentMethod == 'COD',
                      onTap: () => setState(() => _paymentMethod = 'COD'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PayCard(
                      label: 'Bank Transfer',
                      icon: Icons.account_balance_outlined,
                      selected: _paymentMethod == 'BANK_TRANSFER',
                      onTap: () =>
                          setState(() => _paymentMethod = 'BANK_TRANSFER'),
                    ),
                  ),
                ],
              ),
              loyaltyAsync.when(
                data: (loyalty) => loyalty.currentPoints > 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 22),
                          _SectionLabel('Redeem points'),
                          _RedeemSlider(
                            currentPoints: loyalty.currentPoints,
                            pointsToRedeem: _pointsToRedeem,
                            discount: discount,
                            onChanged: (points) {
                              setState(() => _pointsToRedeem = points);
                              ref
                                  .read(checkoutRedeemProvider.notifier)
                                  .set(points);
                              final notifier = ref
                                  .read(redemptionNotifierProvider.notifier);
                              points > 0
                                  ? notifier.validate(points)
                                  : notifier.clear();
                            },
                          ),
                        ],
                      )
                    : const SizedBox(),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 22),
              _SectionLabel('Notes for the barista'),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Any special instructions?'),
              ),
              const SizedBox(height: 24),
              _SummaryCard(
                subtotal: subtotal,
                delivery: delivery,
                tip: widget.tipAmount,
                discount: discount,
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _PlaceOrderBar(
              total: total,
              loading: checkoutState.isLoading,
              onPlace: () => _placeOrder(checkoutState),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(AsyncValue<dynamic> checkoutState) async {
    final addresses = ref.read(addressesNotifierProvider).valueOrNull ?? [];
    final addressId = _selectedAddressId ??
        addresses.where((a) => a.isDefault).firstOrNull?.id ??
        (addresses.isNotEmpty ? addresses.first.id : null);

    if (addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address')),
      );
      return;
    }

    final order = await ref.read(checkoutNotifierProvider.notifier).placeOrder(
          CheckoutRequest(
            addressId: addressId,
            pointsToRedeem: _pointsToRedeem,
            paymentMethod: _paymentMethod,
            tip: widget.tipAmount,
            notes: _notesController.text.isEmpty
                ? null
                : _notesController.text,
          ),
        );

    if (!mounted) return;
    if (order != null) {
      ref.read(checkoutRedeemProvider.notifier).set(0);
      context.goNamed(
        RouteNames.checkoutSuccess,
        extra: {
          'orderId': order.id,
          'total': order.total,
          'pointsEarned': order.pointsEarned,
        },
      );
    } else {
      final err = ref.read(checkoutNotifierProvider);
      if (err.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(err.error!)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ── Building blocks ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: GoogleFonts.fraunces(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface)),
      );
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withValues(alpha: isDark ? 0.12 : 0.08)
              : (isDark ? AppColors.surfaceGlowDark : AppColors.surface),
          borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
          border: Border.all(
            color: selected
                ? AppColors.secondary
                : (isDark ? AppColors.outlineDark : AppColors.outline),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: (!isDark && !selected) ? AppColors.cardShadow : null,
        ),
        child: child,
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _SelectableCard(
        selected: selected,
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.secondary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 14.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayCard extends StatelessWidget {
  const _PayCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SelectableCard(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon,
              color: selected ? AppColors.secondary : AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.secondary
                      : Theme.of(context).colorScheme.onSurface)),
        ],
      ),
    );
  }
}

class _AddAffordance extends StatelessWidget {
  const _AddAffordance({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_rounded, size: 20, color: Color(0xFFB87423)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedeemSlider extends StatelessWidget {
  const _RedeemSlider({
    required this.currentPoints,
    required this.pointsToRedeem,
    required this.discount,
    required this.onChanged,
  });
  final int currentPoints;
  final int pointsToRedeem;
  final double discount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded,
                  color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text('${currentPoints.toPoints} points available',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              if (discount > 0)
                Text('−${discount.toCurrency}',
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondary,
              thumbColor: AppColors.secondary,
              overlayColor: AppColors.secondary.withValues(alpha: 0.15),
              inactiveTrackColor:
                  isDark ? AppColors.backgroundDark : AppColors.surfaceVariant,
              trackHeight: 5,
            ),
            child: Slider(
              value: pointsToRedeem.toDouble(),
              min: 0,
              max: currentPoints.toDouble(),
              divisions: currentPoints >= 100 ? currentPoints ~/ 100 : 1,
              label: '$pointsToRedeem pts',
              onChanged: (v) => onChanged((v / 100).round() * 100),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtotal,
    required this.delivery,
    required this.tip,
    required this.discount,
  });
  final double subtotal;
  final double delivery;
  final double tip;
  final double discount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceGlowDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _row(context, 'Subtotal', subtotal.toCurrency),
          const SizedBox(height: 9),
          _row(context, 'Delivery',
              delivery == 0 ? 'FREE' : delivery.toCurrency,
              valueColor: delivery == 0 ? AppColors.success : null),
          if (tip > 0) ...[
            const SizedBox(height: 9),
            _row(context, 'Tip', tip.toCurrency),
          ],
          if (discount > 0) ...[
            const SizedBox(height: 9),
            _row(context, 'Rewards', '−${discount.toCurrency}',
                valueColor: AppColors.success),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {Color? valueColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary)),
        Text(value,
            style: GoogleFonts.hankenGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.total,
    required this.loading,
    required this.onPlace,
  });
  final double total;
  final bool loading;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xE61C130D) : const Color(0xE6F7F1EA),
            border: Border(
                top: BorderSide(
                    color: isDark
                        ? AppColors.outlineDark
                        : AppColors.outline)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: AppTextStyles.captionText
                            .copyWith(color: AppColors.textSecondary)),
                    Text(total.toCurrency,
                        style: GoogleFonts.fraunces(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Pressable(
                    onTap: loading ? null : onPlace,
                    scale: 0.97,
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Color(0xFFF0C888), strokeWidth: 2))
                          : Text('Place order',
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.onPrimaryDark
                                      : AppColors.onPrimary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
}

// ── Add-address sheet ────────────────────────────────────────────────────────
class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet({required this.onSaved});
  final Future<void> Function(Map<String, dynamic> data) onSaved;

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
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
                    Text('Add address', style: AppTextStyles.headlineSmall),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _Field(label: 'Label', hint: 'e.g. Home, Work', ctrl: _labelCtrl),
                _Field(label: 'Full Name', ctrl: _nameCtrl),
                _Field(label: 'Phone', ctrl: _phoneCtrl, keyboardType: TextInputType.phone),
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
                      if (addr.country.isNotEmpty) {
                        _countryCtrl.text = addr.country;
                      }
                    }),
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: _Field(label: 'City', ctrl: _cityCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _Field(label: 'State', hint: 'e.g. NY', ctrl: _stateCtrl)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _Field(label: 'Postal Code', ctrl: _postalCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _Field(label: 'Country', ctrl: _countryCtrl)),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.secondary,
                  title: const Text('Set as default address'),
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                ),
                const SizedBox(height: 8),
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
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
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

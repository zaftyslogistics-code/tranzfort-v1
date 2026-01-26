/// PriceDisplay Widget
/// 
/// Displays price breakdown with total, advance, and balance amounts.
/// Supports different display modes for cards vs detail screens.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

/// Price type enum matching database
enum PriceType {
  perTon('per_ton'),
  fixed('fixed'),
  negotiable('negotiable');

  final String value;
  const PriceType(this.value);

  static PriceType fromString(String? value) {
    return PriceType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PriceType.negotiable,
    );
  }
}

/// Price data model for display
class PriceData {
  final PriceType priceType;
  final double? ratePerTon;
  final double? fixedPrice;
  final double? weightTons;
  final bool advanceRequired;
  final int advancePercent;

  const PriceData({
    required this.priceType,
    this.ratePerTon,
    this.fixedPrice,
    this.weightTons,
    this.advanceRequired = true,
    this.advancePercent = 70,
  });

  /// Calculate total value based on price type
  double? get totalValue {
    switch (priceType) {
      case PriceType.perTon:
        if (ratePerTon != null && weightTons != null) {
          return ratePerTon! * weightTons!;
        }
        return null;
      case PriceType.fixed:
        return fixedPrice;
      case PriceType.negotiable:
        return null;
    }
  }

  /// Calculate advance amount
  double? get advanceAmount {
    final total = totalValue;
    if (total == null || !advanceRequired) return null;
    return total * (advancePercent / 100);
  }

  /// Calculate balance amount
  double? get balanceAmount {
    final total = totalValue;
    final advance = advanceAmount;
    if (total == null) return null;
    if (advance == null) return total;
    return total - advance;
  }

  /// Is price available (not negotiable)
  bool get hasPriceValue => totalValue != null;

  /// Payment term label
  String get paymentTermLabel {
    if (!advanceRequired) return 'To Pay';
    return 'Advance $advancePercent%';
  }
}

/// Currency formatter for Indian Rupees
final _currencyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

String formatCurrency(double? amount) {
  if (amount == null) return '—';
  return _currencyFormat.format(amount);
}

/// Compact price display for load cards
class PriceDisplayCompact extends StatelessWidget {
  final PriceData priceData;

  const PriceDisplayCompact({
    super.key,
    required this.priceData,
  });

  @override
  Widget build(BuildContext context) {
    if (priceData.priceType == PriceType.negotiable) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.phone_outlined,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Price on call',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Payment term badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: priceData.advanceRequired
                ? AppColors.success.withOpacity(0.15)
                : AppColors.warning.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            priceData.advanceRequired ? 'Advance' : 'To Pay',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: priceData.advanceRequired
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
        ),

        // Rate per ton if applicable
        if (priceData.priceType == PriceType.perTon && priceData.ratePerTon != null) ...[
          const SizedBox(width: 8),
          Text(
            '${formatCurrency(priceData.ratePerTon)}/ton',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Detailed price display for load detail screen
class PriceDisplayDetailed extends StatelessWidget {
  final PriceData priceData;
  final bool showBreakdown;

  const PriceDisplayDetailed({
    super.key,
    required this.priceData,
    this.showBreakdown = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(
          color: AppColors.borderLight.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pricing',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              _buildPriceTypeBadge(),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          if (priceData.priceType == PriceType.negotiable) ...[
            // Negotiable state
            Row(
              children: [
                Icon(
                  Icons.phone_in_talk,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Price will be shared on call',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Price breakdown
            if (priceData.priceType == PriceType.perTon) ...[
              _buildPriceRow(
                'Rate',
                '${formatCurrency(priceData.ratePerTon)} / ton',
              ),
              if (priceData.weightTons != null)
                _buildPriceRow(
                  'Weight',
                  '${priceData.weightTons!.toStringAsFixed(1)} tons',
                ),
              const Divider(height: 16),
            ],

            // Total
            _buildPriceRow(
              'Total Value',
              formatCurrency(priceData.totalValue),
              isTotal: true,
            ),

            if (showBreakdown && priceData.advanceRequired && priceData.totalValue != null) ...[
              const SizedBox(height: AppDimensions.paddingSmall),
              _buildPriceRow(
                'Advance (${priceData.advancePercent}%)',
                formatCurrency(priceData.advanceAmount),
                color: AppColors.success,
              ),
              _buildPriceRow(
                'Balance',
                formatCurrency(priceData.balanceAmount),
                color: AppColors.textSecondary,
              ),
            ],
          ],

          // Payment note
          if (priceData.priceType != PriceType.negotiable) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      priceData.advanceRequired
                          ? 'Advance paid at loading point, balance after unloading'
                          : 'Full payment after unloading',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceTypeBadge() {
    String label;
    Color color;

    switch (priceData.priceType) {
      case PriceType.perTon:
        label = 'Per Ton';
        color = AppColors.primary;
        break;
      case PriceType.fixed:
        label = 'Fixed Price';
        color = AppColors.success;
        break;
      case PriceType.negotiable:
        label = 'Negotiable';
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: color ?? (isTotal ? AppColors.textPrimary : AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Price input section for post load form
class PriceInputSection extends StatelessWidget {
  final PriceType priceType;
  final double? ratePerTon;
  final double? fixedPrice;
  final int advancePercent;
  final double? weightTons;
  final ValueChanged<PriceType> onPriceTypeChanged;
  final ValueChanged<double?> onRateChanged;
  final ValueChanged<double?> onFixedPriceChanged;
  final ValueChanged<int> onAdvancePercentChanged;
  final String? rateError;
  final String? fixedPriceError;

  const PriceInputSection({
    super.key,
    required this.priceType,
    this.ratePerTon,
    this.fixedPrice,
    required this.advancePercent,
    this.weightTons,
    required this.onPriceTypeChanged,
    required this.onRateChanged,
    required this.onFixedPriceChanged,
    required this.onAdvancePercentChanged,
    this.rateError,
    this.fixedPriceError,
  });

  PriceData get _priceData => PriceData(
        priceType: priceType,
        ratePerTon: ratePerTon,
        fixedPrice: fixedPrice,
        weightTons: weightTons,
        advancePercent: advancePercent,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price type selector
        const Text(
          'Price Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Row(
          children: PriceType.values.map((type) {
            final isSelected = priceType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != PriceType.values.last ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onPriceTypeChanged(type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surfaceLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderLight.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      _getPriceTypeLabel(type),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppDimensions.paddingMedium),

        // Rate per ton input
        if (priceType == PriceType.perTon) ...[
          _buildTextField(
            label: 'Rate per Ton (₹)',
            value: ratePerTon?.toString() ?? '',
            hint: 'e.g., 2500',
            error: rateError,
            onChanged: (value) {
              final parsed = double.tryParse(value);
              onRateChanged(parsed);
            },
          ),
        ],

        // Fixed price input
        if (priceType == PriceType.fixed) ...[
          _buildTextField(
            label: 'Total Price (₹)',
            value: fixedPrice?.toString() ?? '',
            hint: 'e.g., 75000',
            error: fixedPriceError,
            onChanged: (value) {
              final parsed = double.tryParse(value);
              onFixedPriceChanged(parsed);
            },
          ),
        ],

        // Advance percentage slider
        if (priceType != PriceType.negotiable) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Advance Payment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$advancePercent%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: advancePercent.toDouble(),
            min: 10,
            max: 90,
            divisions: 8,
            label: '$advancePercent%',
            onChanged: (value) => onAdvancePercentChanged(value.round()),
          ),
        ],

        // Calculated total preview
        if (_priceData.hasPriceValue) ...[
          const SizedBox(height: AppDimensions.paddingMedium),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              border: Border.all(
                color: AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Total Value', formatCurrency(_priceData.totalValue)),
                if (_priceData.advanceAmount != null) ...[
                  _buildSummaryRow(
                    'Advance ($advancePercent%)',
                    formatCurrency(_priceData.advanceAmount),
                  ),
                  _buildSummaryRow(
                    'Balance',
                    formatCurrency(_priceData.balanceAmount),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getPriceTypeLabel(PriceType type) {
    switch (type) {
      case PriceType.perTon:
        return 'Per Ton';
      case PriceType.fixed:
        return 'Fixed';
      case PriceType.negotiable:
        return 'Negotiable';
    }
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required String hint,
    String? error,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXSmall),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: '₹ ',
            errorText: error,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

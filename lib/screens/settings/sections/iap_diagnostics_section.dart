import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/providers/settings_provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/models/subscription_type.dart';
import '../../../utils/theme_constants.dart';

class IAPDiagnosticsSection extends StatefulWidget {
  const IAPDiagnosticsSection({Key? key}) : super(key: key);

  @override
  State<IAPDiagnosticsSection> createState() => _IAPDiagnosticsSectionState();
}

class _IAPDiagnosticsSectionState extends State<IAPDiagnosticsSection> {
  bool _isLoading = false;
  String _diagnosticResults = '';

  Future<String> _runDiagnostics() async {
    try {
      String results = 'IAP DIAGNOSTICS RESULTS:\n\n';

      // Check if IAP is available
      final revenueCatService =
          Provider.of<RevenueCatService>(context, listen: false);
      final bool isAvailable = !revenueCatService.isLoading;
      results += '${isAvailable ? "✅" : "❌"} IAP Available: $isAvailable\n\n';

      if (!isAvailable) {
        return '$results IAP is not available on this device. Please check your device settings.';
      }

      // Check receipt info
      if (Platform.isIOS) {
        results += 'RECEIPT INFO:\n';

        if (revenueCatService.customerInfo != null) {
          results += '✅ Customer Info exists\n';

          if (revenueCatService.customerInfo!.entitlements.active.isNotEmpty) {
            results +=
                '✅ Found ${revenueCatService.customerInfo!.entitlements.active.length} active entitlements\n';

            for (var entitlement in revenueCatService
                .customerInfo!.entitlements.active.entries) {
              results += '  • Entitlement: ${entitlement.key}\n';
              results +=
                  '    Product: ${entitlement.value.productIdentifier}\n';
              results +=
                  '    Expiration: ${entitlement.value.expirationDate}\n';
            }
          } else {
            results += '❌ No active entitlements found\n';
          }
        } else {
          results += '❌ No customer info available\n';
        }

        results += '\n';
      }

      // Check active subscription
      results += 'SUBSCRIPTION STATUS:\n';
      results +=
          '${revenueCatService.isPremium ? "✅" : "❌"} Premium: ${revenueCatService.isPremium}\n';
      results +=
          '✅ Subscription Type: ${revenueCatService.activeSubscription.toString().split('.').last}\n';

      if (revenueCatService.expiryDate != null) {
        results += '✅ Expiry Date: ${revenueCatService.expiryDate}\n';
        results +=
            '✅ Is Active: ${revenueCatService.expiryDate!.isAfter(DateTime.now())}\n';
      } else if (revenueCatService.activeSubscription ==
          SubscriptionType.lifetime) {
        results += '✅ Expiry Date: Never (Lifetime)\n';
      } else {
        results += '❌ No expiry date found\n';
      }

      results += '\n';

      // Check available products
      results += 'AVAILABLE PRODUCTS:\n';
      if (revenueCatService.offerings == null ||
          revenueCatService.offerings!.current == null ||
          revenueCatService.offerings!.current!.availablePackages.isEmpty) {
        results += '❌ No products available\n';
      } else {
        for (var package
            in revenueCatService.offerings!.current!.availablePackages) {
          results +=
              '✅ ${package.identifier}: ${package.storeProduct.priceString}\n';
        }
      }

      return results;
    } catch (e) {
      return 'Error running diagnostics: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'In-App Purchase Diagnostics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: settings.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'If you\'re experiencing issues with premium features or purchases, run the diagnostics to help identify the problem.',
          style: TextStyle(
            fontSize: 14,
            color: settings.textColor
                .withAlpha(ThemeConstants.opacityToAlpha(0.8)),
          ),
        ),
        const SizedBox(height: 16),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: CupertinoColors.activeBlue,
          borderRadius: BorderRadius.circular(12),
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                    _diagnosticResults = 'Running diagnostics...';
                  });

                  final results = await _runDiagnostics();

                  setState(() {
                    _diagnosticResults = results;
                    _isLoading = false;
                  });
                },
          child: _isLoading
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : const Text(
                  'Run Diagnostics',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        if (_diagnosticResults.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: settings.isDarkTheme
                  ? CupertinoColors.systemGrey6.darkColor
                  : CupertinoColors.systemGrey6.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _diagnosticResults,
              style: TextStyle(
                fontFamily: 'Menlo',
                fontSize: 12,
                color: settings.textColor,
              ),
              selectionColor: CupertinoColors.activeBlue
                  .withAlpha(ThemeConstants.opacityToAlpha(0.2)),
            ),
          ),
        ],
      ],
    );
  }
}

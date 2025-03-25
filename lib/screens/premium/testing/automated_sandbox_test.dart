import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timemaster/services/revenue_cat_service.dart';
import 'package:pomodoro_timemaster/screens/premium/testing/sandbox_testing_helper.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Automated sandbox testing tool that follows the testing checklist
/// This screen allows users to run tests and mark them as completed
class AutomatedSandboxTestScreen extends StatefulWidget {
  const AutomatedSandboxTestScreen({Key? key}) : super(key: key);

  @override
  State<AutomatedSandboxTestScreen> createState() =>
      _AutomatedSandboxTestScreenState();
}

class _AutomatedSandboxTestScreenState
    extends State<AutomatedSandboxTestScreen> {
  bool _isInitialized = false;
  bool _isLoading = true;
  late RevenueCatService _revenueCatService;

  // Test categories with their tests
  late List<TestCategory> _testCategories;

  // Initialize test categories with deferred access to _revenueCatService
  void _initializeTestCategories() {
    _testCategories = [
      TestCategory(
        name: 'Prerequisites',
        tests: [
          Test(
            id: 'prereq_sandbox_account',
            name: 'Signed into sandbox test account',
            description:
                'Verify you are signed into a sandbox test account on your device',
            isPrerequisite: true,
          ),
          Test(
            id: 'prereq_sandbox_mode',
            name: 'Sandbox testing mode enabled',
            description:
                'Verify sandbox testing mode is enabled in the app settings',
            isPrerequisite: true,
            automatedCheck: () async {
              return await SandboxTestingHelper.isSandboxTestingEnabled();
            },
          ),
          Test(
            id: 'prereq_network',
            name: 'Stable internet connection',
            description: 'Verify you have a stable internet connection',
            isPrerequisite: true,
          ),
          Test(
            id: 'prereq_api_keys',
            name: 'RevenueCat API keys configured',
            description:
                'Verify your RevenueCat API keys are configured correctly',
            isPrerequisite: true,
          ),
        ],
      ),
      TestCategory(
        name: 'Basic Purchase Flow Tests',
        tests: [
          Test(
            id: 'products_loading',
            name: 'Products Loading',
            description:
                'Verify all products load correctly with proper titles and prices',
            automatedCheck: () async {
              // Check if offerings are loaded
              if (_revenueCatService.offerings == null) {
                return false;
              }
              return _revenueCatService.offerings!.current != null &&
                  _revenueCatService
                      .offerings!.current!.availablePackages.isNotEmpty;
            },
          ),
          Test(
            id: 'product_descriptions',
            name: 'Product Descriptions',
            description: 'Verify product descriptions are displayed correctly',
          ),
          Test(
            id: 'payment_sheet',
            name: 'Payment Sheet Presentation',
            description:
                'Verify tapping "Subscribe" shows the Apple payment sheet',
          ),
          Test(
            id: 'purchase_completion',
            name: 'Purchase Completion',
            description: 'Verify successful purchase is processed correctly',
          ),
        ],
      ),
      TestCategory(
        name: 'Error Handling Tests',
        tests: [
          Test(
            id: 'network_interruption',
            name: 'Network Interruption',
            description:
                'Test purchase with airplane mode enabled mid-purchase',
            automated: true,
            onRun: (BuildContext context, Function(bool) onComplete) async {
              SandboxTestingHelper.logSandboxEvent(
                  'AutomatedTest', 'Starting Network Interruption test');

              // Show instructions dialog
              await showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Network Interruption Test'),
                  content: const Text('1. Tap "Start Test"\n'
                      '2. When prompted, select a subscription\n'
                      '3. When payment sheet appears, enable Airplane Mode\n'
                      '4. Wait 30 seconds, then disable Airplane Mode\n'
                      '5. Verify transaction completes after reconnection'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop(context);
                        onComplete(false);
                      },
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop(context);
                        _startNetworkInterruptionTest(context, onComplete);
                      },
                      child: const Text('Start Test'),
                    ),
                  ],
                ),
              );
            },
          ),
          Test(
            id: 'user_cancellation',
            name: 'User Cancellation',
            description:
                'Cancel purchase from payment sheet and verify graceful handling',
          ),
          Test(
            id: 'payment_sheet_timeout',
            name: 'Payment Sheet Timeout',
            description:
                'Let payment sheet time out without user action and verify handling',
          ),
        ],
      ),
      TestCategory(
        name: 'Advanced Tests',
        tests: [
          Test(
            id: 'subscription_renewal',
            name: 'Subscription Renewal',
            description:
                'Verify auto-renewable subscription renewal in sandbox',
          ),
          Test(
            id: 'restore_purchases',
            name: 'Restore Purchases',
            description: 'Test restore purchases functionality',
            automated: true,
            onRun: (BuildContext context, Function(bool) onComplete) async {
              SandboxTestingHelper.logSandboxEvent(
                  'AutomatedTest', 'Starting Restore Purchases test');

              try {
                // Attempt to restore purchases
                await _revenueCatService.restorePurchases();

                // Log the result
                SandboxTestingHelper.logSandboxEvent(
                    'AutomatedTest', 'Restore completed successfully');

                // Show completion dialog
                await showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Restore Completed'),
                    content: const Text(
                        'Restore purchases has been completed. Did the restore work correctly?'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                          onComplete(false);
                        },
                        child: const Text('No'),
                      ),
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                          onComplete(true);
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                // Log the error
                SandboxTestingHelper.logSandboxEvent(
                    'AutomatedTest', 'Restore error: $e');

                // Show error dialog
                await showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Restore Failed'),
                    content: Text('Error: $e'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                          onComplete(false);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          Test(
            id: 'app_restart',
            name: 'App Restart Scenarios',
            description:
                'Complete purchase and immediately force-close the app',
          ),
        ],
      ),
      TestCategory(
        name: 'Transaction Queue Tests',
        tests: [
          Test(
            id: 'queue_management',
            name: 'Queue Management',
            description: 'Verify transaction queue is processed on app launch',
          ),
          Test(
            id: 'force_queue_processing',
            name: 'Force Queue Processing',
            description:
                'Test manually forcing the transaction queue to process',
            automated: true,
            onRun: (BuildContext context, Function(bool) onComplete) async {
              SandboxTestingHelper.logSandboxEvent(
                  'AutomatedTest', 'Starting Force Queue Processing test');

              // Get current queue items
              final initialQueueItems =
                  _revenueCatService.getTransactionQueueItems();
              final initialCount = initialQueueItems.length;

              SandboxTestingHelper.logSandboxEvent(
                  'AutomatedTest', 'Initial queue items: $initialCount');

              // Force process the queue
              await _revenueCatService.forceProcessTransactionQueue();

              // Get updated queue items
              final updatedQueueItems =
                  _revenueCatService.getTransactionQueueItems();
              final updatedCount = updatedQueueItems.length;

              SandboxTestingHelper.logSandboxEvent('AutomatedTest',
                  'Queue items after processing: $updatedCount');

              // Show completion dialog
              await showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Queue Processing Complete'),
                  content: Text('Initial queue items: $initialCount\n'
                      'Queue items after processing: $updatedCount\n\n'
                      'Did queue processing complete successfully?'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop(context);
                        onComplete(false);
                      },
                      child: const Text('No'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.pop(context);
                        onComplete(true);
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];
  }

  // Load completed tests from preferences
  Map<String, bool> _completedTests = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedTests();
  }

  Future<void> _loadCompletedTests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get completed tests from preferences
      final prefs = await SharedPreferences.getInstance();
      final completedTestsJson =
          prefs.getString('completed_sandbox_tests') ?? '{}';
      _completedTests = Map<String, bool>.from(
          Map<String, dynamic>.from(json.decode(completedTestsJson)));
    } catch (e) {
      debugPrint('Error loading completed tests: $e');
      _completedTests = {};
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveCompletedTests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'completed_sandbox_tests', json.encode(_completedTests));
    } catch (e) {
      debugPrint('Error saving completed tests: $e');
    }
  }

  void _initializeTests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Enable sandbox testing if not already enabled
      final isEnabled = await SandboxTestingHelper.isSandboxTestingEnabled();
      if (!isEnabled) {
        debugPrint('Sandbox testing not enabled, initializing...');
        await SandboxTestingHelper.initializeManualTest();

        // Verify it was enabled correctly
        final checkEnabled =
            await SandboxTestingHelper.isSandboxTestingEnabled();
        if (!checkEnabled) {
          debugPrint('⚠️ Warning: Failed to enable sandbox testing!');
          // Try direct approach
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('sandbox_testing_enabled', true);
        }
      } else {
        debugPrint('Sandbox testing already enabled');
      }

      // Get RevenueCat service
      _revenueCatService =
          Provider.of<RevenueCatService>(context, listen: false);

      // Initialize test categories
      _initializeTestCategories();

      // Run automated checks for prerequisites
      for (final category in _testCategories) {
        for (final test in category.tests) {
          if (test.automatedCheck != null) {
            final result = await test.automatedCheck!();
            setState(() {
              _completedTests[test.id] = result;
            });
          }
        }
      }

      await _saveCompletedTests();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing tests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _markTestCompleted(Test test, bool isCompleted) {
    setState(() {
      _completedTests[test.id] = isCompleted;
    });
    _saveCompletedTests();

    SandboxTestingHelper.logSandboxEvent('AutomatedTest',
        'Test "${test.name}" marked as ${isCompleted ? 'completed' : 'incomplete'}');
  }

  Future<void> _runTest(Test test) async {
    if (test.automated && test.onRun != null) {
      await test.onRun!(context, (bool success) {
        _markTestCompleted(test, success);
      });
    } else {
      // For manual tests, show instructions and let user mark as completed
      final isCompleted = await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text(test.name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(test.description),
                  const SizedBox(height: 16),
                  const Text('Have you completed this test successfully?'),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          ) ??
          false;

      _markTestCompleted(test, isCompleted);
    }
  }

  void _resetAllTests() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset All Tests'),
        content: const Text('Are you sure you want to reset all test results?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _completedTests.clear();
              });
              _saveCompletedTests();
              SandboxTestingHelper.logSandboxEvent(
                  'AutomatedTest', 'All tests have been reset');
            },
            child: const Text('Reset'),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTestItem(Test test) {
    final isCompleted = _completedTests[test.id] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Checkbox or indicator
          isCompleted
              ? const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: CupertinoColors.activeGreen,
                  size: 22,
                )
              : Icon(
                  test.isPrerequisite
                      ? CupertinoIcons.exclamationmark_circle
                      : CupertinoIcons.circle,
                  color: test.isPrerequisite
                      ? CupertinoColors.systemOrange
                      : CupertinoColors.systemGrey,
                  size: 22,
                ),
          const SizedBox(width: 12),
          // Test details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  test.description,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Run button
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text(
              test.automated ? 'Run' : 'Test',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.activeBlue,
              ),
            ),
            onPressed: () => _runTest(test),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(TestCategory category) {
    final tests = category.tests;

    // Calculate completion rate for the category
    int completedCount = 0;
    for (final test in tests) {
      if (_completedTests[test.id] == true) {
        completedCount++;
      }
    }
    final completionRate = tests.isEmpty ? 0 : completedCount / tests.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: CupertinoColors.systemGrey6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$completedCount/${tests.length}',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Progress bar
              Container(
                height: 4,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: (completionRate * 100).round(),
                      child: Container(
                        color: CupertinoColors.activeGreen,
                      ),
                    ),
                    Expanded(
                      flex: ((1 - completionRate) * 100).round(),
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...tests.map(_buildTestItem).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize on first build
    if (!_isInitialized && !_isLoading) {
      _initializeTests();
    }

    // Calculate overall completion rate
    int totalTests = 0;
    int totalCompleted = 0;

    // Check if test categories are initialized
    if (_isInitialized) {
      for (final category in _testCategories) {
        for (final test in category.tests) {
          totalTests++;
          if (_completedTests[test.id] == true) {
            totalCompleted++;
          }
        }
      }
    }

    final overallCompletionRate =
        totalTests > 0 ? totalCompleted / totalTests : 0.0;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Automated Sandbox Testing'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: _resetAllTests,
        ),
      ),
      child: SafeArea(
        child: _isLoading || !_isInitialized
            ? const Center(child: CupertinoActivityIndicator())
            : Column(
                children: [
                  // Overall progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.systemGrey5,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Overall Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              '$totalCompleted of $totalTests complete',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Progress bar
                        Container(
                          height: 6,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: (overallCompletionRate * 100).round(),
                                child: Container(
                                  color: CupertinoColors.activeGreen,
                                ),
                              ),
                              Expanded(
                                flex:
                                    ((1 - overallCompletionRate) * 100).round(),
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Test categories
                  Expanded(
                    child: ListView(
                      children:
                          _testCategories.map(_buildCategorySection).toList(),
                    ),
                  ),

                  // View logs button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      border: Border(
                        top: BorderSide(
                          color: CupertinoColors.systemGrey5,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Text('View Testing Logs'),
                        onPressed: () =>
                            SandboxTestingHelper.showSandboxLogs(context),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _startNetworkInterruptionTest(
      BuildContext context, Function(bool) onComplete) async {
    // Find a product to purchase
    final offerings = _revenueCatService.offerings;
    if (offerings == null ||
        offerings.current == null ||
        offerings.current!.availablePackages.isEmpty) {
      SandboxTestingHelper.logSandboxEvent('AutomatedTest',
          'No products available for network interruption test');

      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Test Failed'),
          content: const Text('No products are available for purchase'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                onComplete(false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Get the first available package
    final package = offerings.current!.availablePackages.first;

    SandboxTestingHelper.logSandboxEvent('AutomatedTest',
        'Starting network interruption test with product: ${package.identifier}');

    // Show instructions dialog
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Enable Airplane Mode'),
        content: const Text('The purchase will start when you tap "Begin".\n\n'
            'When the payment sheet appears, quickly enable Airplane Mode in your device settings.\n\n'
            'Wait 30 seconds with Airplane Mode on, then disable it.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              onComplete(false);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);

              // Start the purchase process
              _revenueCatService.purchasePackage(package);

              // Show follow-up dialog after a delay
              Future.delayed(const Duration(seconds: 45), () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Did the test succeed?'),
                    content: const Text(
                        'After turning Airplane Mode off, did the transaction:\n'
                        '1. Complete successfully, or\n'
                        '2. Show a retry option that worked when tapped?'),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                          onComplete(false);
                        },
                        child: const Text('No'),
                      ),
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                          onComplete(true);
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              });
            },
            child: const Text('Begin'),
          ),
        ],
      ),
    );
  }
}

/// Model for a test category
class TestCategory {
  final String name;
  final List<Test> tests;

  TestCategory({
    required this.name,
    required this.tests,
  });
}

/// Model for an individual test
class Test {
  final String id;
  final String name;
  final String description;
  final bool isPrerequisite;
  final bool automated;
  final Function(BuildContext, Function(bool))? onRun;
  final Future<bool> Function()? automatedCheck;

  Test({
    required this.id,
    required this.name,
    required this.description,
    this.isPrerequisite = false,
    this.automated = false,
    this.onRun,
    this.automatedCheck,
  });
}

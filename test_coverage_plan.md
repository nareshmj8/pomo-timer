# Test Coverage Improvement Plan

Current coverage: 52.4% (2983 of 5690 lines)
Target: 80% or higher

## Priority 1: Large files with 0% coverage
1.1. ✅ Premium Screen View (`lib/screens/premium/views/premium_screen_view.dart`) - 196 lines
1.2. ✅ Notification Services (`lib/services/notification/*.dart`) - 173 lines total
1.3. ✅ Statistics Screen (`lib/screens/statistics_screen.dart`) - 397 lines

## Priority 2: Files with large impact and low coverage
2.1. ✅ Restore Purchases Handler (`lib/screens/premium/components/restore_purchases_handler.dart`) - 55 lines
2.2. ✅ Premium Debug Menu (`lib/screens/premium/widgets/premium_debug_menu.dart`) - 74 lines
2.3. ✅ History Screen (`lib/screens/history/history_screen.dart`) - 52 lines
2.4. ✅ Main App (`lib/main.dart`) - 61 lines

## Priority 3: Files with moderate coverage needing improvement
3.1. Notifications Settings (`lib/screens/settings/components/notifications_section.dart`) - 82 lines
3.2. ✅ Data Section Settings (`lib/screens/settings/components/data_section.dart`) - 118 lines
3.3. Reset Section Settings (`lib/screens/settings/components/reset_section.dart`) - 81 lines
3.4. Purchase Success Handler (`lib/animations/purchase_success_handler.dart`) - 7 lines

## Priority 4: Fix missing coverage in core functionality
4.1. Settings Provider (`lib/providers/settings_provider.dart`) - 205 lines
4.2. Revenue Cat Service (`lib/services/revenue_cat_service.dart`) - 388 lines
4.3. Premium Controller (`lib/screens/premium/controllers/premium_controller.dart`) - 150 lines
4.4. Session Cycle Section Settings (`lib/screens/settings/components/session_cycle_section.dart`) - 65 lines

## Progress Tracking

| Date       | Task Completed                   | Coverage Change   |
|------------|----------------------------------|------------------|
| March 22   | Premium Screen View (1.1)        | 49.4% → 50.5%    |
| March 22   | Premium Debug Menu (2.2)         | 50.5% → 50.8%    |
| March 22   | History Screen (2.3)             | 50.8% → 51.4%    |
| March 22   | Main App (2.4)                   | 51.4% → 51.4%    |
| March 22   | Restore Purchases Handler (2.1)  | 51.4% → 51.5%    |
| March 22   | Data Section Settings (3.2)      | 51.5% → 52.4%    |

## Check Current Coverage
After implementing new tests, run:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Notes
- Focus on increasing coverage of core functionality first
- Add integration tests for critical user flows
- Don't waste time on auto-generated code
- Prioritize files with higher line counts 
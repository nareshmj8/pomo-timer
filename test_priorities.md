# Test Prioritization

Generated on: Thu Mar 20 17:56:35 IST 2025

## High Priority (Core Services & Providers)

These files represent core functionality and should be tested first:

| File | Lines | Priority Reason |
|------|-------|----------------|
| lib/providers/timer_provider.dart |       57 | Core timer functionality |
| lib/services/backup_service.dart |      289 | Core service |
| lib/services/iap/iap_models.dart |       25 | In-app purchases |
| lib/services/iap/iap_service_new.dart |        1 | In-app purchases |
| lib/services/iap/iap_storage.dart |        1 | In-app purchases |
| lib/services/iap/product_manager.dart |        1 | In-app purchases |
| lib/services/iap/purchase_handler.dart |        1 | In-app purchases |
| lib/services/iap/receipt_verifier.dart |        1 | In-app purchases |
| lib/services/iap/subscription_manager.dart |        1 | In-app purchases |
| lib/services/notification/notification_models.dart |       34 | User notifications |
| lib/services/notification/notification_service_new.dart |        8 | User notifications |
| lib/services/statistics_service.dart |      159 | Core service |
| lib/services/timer_service.dart |      138 | Core timer functionality |

## Medium Priority (Models & Utilities)

These files handle data structures and utility functions:

| File | Lines | Priority Reason |
|------|-------|----------------|
| lib/models/statistics_data.dart |       26 | Data structure |
| lib/screens/settings/utils/settings_dialogs.dart |      250 | Utility functions |
| lib/screens/statistics/models/statistics_data.dart |       20 | Data structure |
| lib/widgets/statistics/utils/chart_formatting.dart |       55 | Utility functions |

## Lower Priority (UI Components)

These files are UI components that should be tested after core functionality:

| File | Lines | Component Type |
|------|-------|---------------|
| lib/screens/appearance_settings_screen.dart |       96 | Screen |
| lib/screens/iap_test_screen.dart |      206 | Screen |
| lib/screens/legal/legal_section.dart |      103 | Screen |
| lib/screens/premium/components/active_subscription_info.dart |      171 | Screen |
| lib/screens/premium/components/feature_card.dart |      122 | Screen |
| lib/screens/premium/components/index.dart |        6 | Screen |
| lib/screens/premium/components/loading_indicator.dart |       37 | Screen |
| lib/screens/premium/components/premium_footer.dart |      204 | Screen |
| lib/screens/premium/components/premium_plan_card.dart |      269 | Screen |
| lib/screens/premium/components/pricing_container.dart |      253 | Screen |
| lib/screens/premium/index.dart |        2 | Screen |
| lib/screens/premium_screen.dart |        3 | Screen |
| lib/screens/settings/about_section.dart |       78 | Screen |
| lib/screens/settings/appearance_section.dart |       74 | Screen |
| lib/screens/settings/data_settings_page.dart |      294 | Screen |
| lib/screens/settings/data_sync_section.dart |      205 | Screen |
| lib/screens/settings/main_settings_screen.dart |       46 | Screen |
| lib/screens/settings/notifications_section.dart |       44 | Screen |
| lib/screens/settings/premium_section.dart |      134 | Screen |
| lib/screens/settings/reset_section.dart |       67 | Screen |
| lib/screens/settings/sections/about_section.dart |      131 | Screen |
| lib/screens/settings/sections/data_sync_section.dart |      140 | Screen |
| lib/screens/settings/sections/notifications_section.dart |      137 | Screen |
| lib/screens/settings/sections/premium_section.dart |      210 | Screen |
| lib/screens/settings/sections/reset_section.dart |      226 | Screen |
| lib/screens/settings/sections/theme_section.dart |       92 | Screen |
| lib/screens/settings/session_cycle_section.dart |       93 | Screen |
| lib/screens/settings/settings_dialogs.dart |       53 | Screen |
| lib/screens/settings/testing/icloud_sync_test_helper.dart |      244 | Screen |
| lib/screens/settings/testing/icloud_sync_test_screen.dart |      324 | Screen |
| lib/screens/settings/timer_settings_section.dart |      121 | Screen |
| lib/screens/settings/utils/settings_dialogs.dart |      250 | Screen |
| lib/screens/settings/widgets/animated_theme_tile.dart |      137 | Screen |
| lib/screens/settings/widgets/settings_list_tile_container.dart |       36 | Screen |
| lib/screens/settings/widgets/settings_section_footer.dart |       35 | Screen |
| lib/screens/settings/widgets/settings_section_header.dart |       36 | Screen |
| lib/screens/settings/widgets/settings_slider_tile.dart |       80 | Screen |
| lib/screens/statistics/components/index.dart |        5 | Screen |
| lib/screens/statistics/components/statistics_overview.dart |      139 | Screen |
| lib/screens/statistics/models/statistics_data.dart |       20 | Screen |
| lib/screens/statistics/statistics_grid.dart |        1 | Screen |
| lib/screens/timer_settings_screen.dart |      246 | Screen |
| lib/widgets/settings/settings_list_tile_container.dart |       61 | Widget |
| lib/widgets/settings/settings_section_footer.dart |       37 | Widget |
| lib/widgets/settings/settings_section_header.dart |       38 | Widget |
| lib/widgets/statistics/components/chart_legend.dart |       67 | Widget |
| lib/widgets/statistics/statistics_cards.dart |       98 | Widget |
| lib/widgets/statistics/statistics_charts.dart |      172 | Widget |
| lib/widgets/statistics/statistics_header.dart |      122 | Widget |
| lib/widgets/statistics/utils/chart_formatting.dart |       55 | Widget |
| lib/widgets/timer/category_selector.dart |      171 | Widget |
| lib/widgets/timer/timer_controls.dart |      246 | Widget |

## Next Steps

1. Begin by creating tests for high-priority core services and providers
2. Then move to medium-priority models and utilities
3. Finally test UI components with widget and integration tests


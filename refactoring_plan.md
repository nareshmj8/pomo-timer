# Code Refactoring Plan

This document outlines the plan for breaking down large files in the codebase to improve maintainability while preserving functionality.

## Priority Order

Files will be refactored in the following order:

### Critical Priority (>1000 lines)
- [x] lib/services/notification_service.dart (1432 lines)
- [ ] lib/services/revenue_cat_service.dart (1429 lines)
- [ ] lib/services/cloudkit_service.dart (1120 lines)

### High Priority (500-1000 lines)
- [ ] lib/services/database_service.dart (721 lines)
- [ ] lib/screens/statistics_screen.dart (880 lines)
- [ ] lib/screens/timer_screen.dart (710 lines)
- [ ] lib/providers/settings/timer_settings_provider.dart (649 lines)
- [ ] lib/screens/premium/views/premium_screen_view.dart (506 lines)

### Medium Priority (300-500 lines)
- [ ] lib/screens/premium/controllers/premium_controller.dart (458 lines)
- [ ] lib/providers/settings_provider.dart (408 lines)
- [ ] lib/main.dart (407 lines)
- [ ] lib/widgets/statistics/chart_card.dart (396 lines)
- [ ] lib/screens/history_screen.dart (388 lines)

## Refactoring Guidelines

### For Service Files
- Separate service files into multiple smaller files based on functionality
- Create interface files for each service
- Use composition over inheritance
- Maintain backward compatibility with existing code

### For Widget/Screen Files
- Extract reusable widgets into separate files
- Create helper/utility methods for complex logic
- Use extension methods where appropriate
- Create separate controllers for business logic

## Testing Strategy
- After each file is refactored, run tests to ensure functionality is preserved
- Manual testing of affected features after refactoring

## Progress Tracking
Progress will be updated in this document as files are refactored.

### Completed Refactorings

#### 1. NotificationService (1432 lines)
Split into the following smaller components:
- lib/services/notification/notification_service.dart (main coordinator, ~200 lines)
- lib/services/notification/notification_sound_manager.dart (~120 lines)
- lib/services/notification/notification_scheduler.dart (~290 lines)
- lib/services/notification/notification_tracking.dart (~190 lines)
- lib/services/notification/notification_ui.dart (~180 lines)
- lib/services/notification/expiry_notification_manager.dart (~120 lines)
- lib/services/notification/notification_channel_manager.dart (~80 lines)

This refactoring significantly improves maintainability by:
- Applying single responsibility principle to each component
- Improving testability of individual components
- Making the code more modular and easier to understand
- Reducing cognitive load when working on specific notification functionality 
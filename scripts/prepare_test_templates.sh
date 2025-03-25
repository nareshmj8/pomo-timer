#!/bin/bash

# Script to prepare test templates for high-priority services
# This script will:
# 1. Create directory structure for tests if it doesn't exist
# 2. Create test templates for each service with proper imports and structure
# 3. Update the testing tracker

echo "🧪 Preparing test templates for high-priority services..."

# Make sure we're in the project root
cd "$(dirname "$0")/.." || exit 1

# Create test directory structure if it doesn't exist
mkdir -p test/services
mkdir -p test/providers
mkdir -p test/models
mkdir -p test/widgets
mkdir -p test/mocks

# Function to create a service test template
create_service_test_template() {
  local service_name=$1
  local test_file="test/services/${service_name}_test.dart"
  
  if [ -f "$test_file" ]; then
    echo "⚠️ Test file for $service_name already exists, skipping"
    return
  fi
  
  # Create test file with template
  cat > "$test_file" << EOL
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// TODO: Import the service under test and any dependencies
// import 'package:your_app/services/${service_name}.dart';

// TODO: Create mock dependencies if needed
// class MockDependency extends Mock implements Dependency {}

void main() {
  // TODO: Replace with actual service name
  group('${service_name^} Service Tests', () {
    // TODO: Declare variables for the service and mocks
    // late ${service_name^}Service service;
    // late MockDependency mockDependency;

    setUp(() {
      // TODO: Initialize mocks and service instance
      // mockDependency = MockDependency();
      // service = ${service_name^}Service(dependency: mockDependency);
    });

    test('should initialize properly', () {
      // TODO: Write test for initialization
      // expect(service, isNotNull);
    });

    // TODO: Add more tests for each method in the service
    // Example:
    // test('method should perform expected action', () {
    //   // Arrange
    //   when(mockDependency.someMethod()).thenReturn('value');
    //
    //   // Act
    //   final result = service.methodUnderTest();
    //
    //   // Assert
    //   expect(result, equals(expectedValue));
    //   verify(mockDependency.someMethod()).called(1);
    // });
  });
}
EOL

  echo "✅ Created test template for $service_name"
}

# Function to create a provider test template
create_provider_test_template() {
  local provider_name=$1
  local test_file="test/providers/${provider_name}_test.dart"
  
  if [ -f "$test_file" ]; then
    echo "⚠️ Test file for $provider_name already exists, skipping"
    return
  fi
  
  # Create test file with template
  cat > "$test_file" << EOL
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
// TODO: Import the provider under test and any dependencies
// import 'package:your_app/providers/${provider_name}.dart';

// TODO: Create mock dependencies if needed
// class MockService extends Mock implements Service {}

void main() {
  // TODO: Replace with actual provider name
  group('${provider_name^} Provider Tests', () {
    // TODO: Declare variables for the provider and mocks
    // late ${provider_name^}Provider provider;
    // late MockService mockService;

    setUp(() {
      // TODO: Initialize mocks and provider instance
      // mockService = MockService();
      // provider = ${provider_name^}Provider(service: mockService);
    });

    test('should initialize with default values', () {
      // TODO: Write test for initialization
      // expect(provider.someValue, equals(defaultValue));
    });

    // TODO: Add more tests for each method in the provider
    // Example:
    // test('method should update state correctly', () {
    //   // Arrange
    //   when(mockService.someMethod()).thenReturn('value');
    //
    //   // Act
    //   provider.methodUnderTest();
    //
    //   // Assert
    //   expect(provider.someValue, equals(newValue));
    //   verify(mockService.someMethod()).called(1);
    // });
  });
}
EOL

  echo "✅ Created test template for $provider_name"
}

# Create test templates for high-priority services
echo "📝 Creating test templates for high-priority services..."
create_service_test_template "timer_service"
create_service_test_template "notification_service"
create_service_test_template "iap_service"
create_service_test_template "analytics_service"
create_service_test_template "statistics_service"

# Create test templates for high-priority providers
echo "📝 Creating test templates for high-priority providers..."
create_provider_test_template "timer_provider"
create_provider_test_template "timer_settings_provider"
create_provider_test_template "statistics_provider"
create_provider_test_template "theme_settings_provider"

# Create a mock helper file
echo "📝 Creating mock helper file..."
cat > "test/mocks/mock_helpers.dart" << EOL
import 'package:mockito/mockito.dart';

// This file contains common mock implementations for services and other dependencies
// to be used across multiple test files.

// Add mock implementations here

EOL

# Update the testing tracker
echo "🔄 Updating testing tracker..."

# Mark the tasks as in progress in the testing_tracker.md
sed -i '' 's/- \[ \] 2.1 Timer functionality tests/- \[~\] 2.1 Timer functionality tests - In progress/' testing_tracker.md
sed -i '' 's/- \[ \] 2.2 Notification service tests/- \[~\] 2.2 Notification service tests - In progress/' testing_tracker.md
sed -i '' 's/- \[ \] 2.3 RevenueCat integration tests/- \[~\] 2.3 RevenueCat integration tests - In progress/' testing_tracker.md
sed -i '' 's/- \[ \] 2.4 Analytics service tests/- \[~\] 2.4 Analytics service tests - In progress/' testing_tracker.md
sed -i '' 's/- \[ \] 2.5 Settings provider tests/- \[~\] 2.5 Settings provider tests - In progress/' testing_tracker.md

# Update overall progress for task 2
sed -i '' 's/- \[ \] \*\*2. Generate Automated Tests\*\* - 0% complete/- \[~\] \*\*2. Generate Automated Tests\*\* - 10% complete/' testing_tracker.md

echo "🎉 Test templates prepared! Ready to start implementing tests." 
#!/bin/bash

echo "Searching for references to app-logo.png in the codebase..."
grep -r "app-logo.png" --include="*.dart" --include="*.yaml" --include="*.xml" --include="*.json" .

echo ""
echo "If any files were listed above, they still contain references to the old logo file."
echo "Please update them to use 'assets/appstore.png' instead." 
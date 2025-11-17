# Gateway Configuration Migration

## Changes Made

### File Changes
- **Old**: `.env` (root level, dotenv format)
- **New**: `appsettings.json` (root level, JSON format)

### Reason
- `.env` files are conventionally NOT committed to repositories
- We have only ONE `.env` file now: `.devcontainer/.env` (for personal devcontainer config)
- Gateway configurations are safe to commit and should be shared across the team
- JSON format provides better structure and validation vs flat key=value format
- Cleaner representation of array data (gateways list) vs GATEWAY_1_, GATEWAY_2_ pattern

### Updated Files
1. **appsettings.json** - New JSON-based configuration with structured gateway array
2. **pubspec.yaml** - Changed asset reference to `appsettings.json`, removed `flutter_dotenv` dependency
3. **lib/dart_wing/core/gateway_manager.dart** - Rewritten to use JSON parsing instead of dotenv
4. **pubspec.lock** - Updated to remove flutter_dotenv package

### Configuration Files Summary
- **`.devcontainer/.env`** - DevContainer configuration (NOT committed, personal settings)
- **`appsettings.json`** - Application gateway configuration (COMMITTED, shared across team)

## Notes
- `lib/dart_wing` is an unpopulated git submodule
- Changes to `gateway_manager.dart` may need to be committed separately in that submodule if it becomes active

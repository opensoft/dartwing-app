# CI/CD Setup and Submodule Handling

## Overview

This project uses GitHub Actions for CI/CD with intelligent handling of private submodules. The build system can operate in two modes:

1. **Full Build Mode**: When submodule access is available
2. **Test-Only Mode**: When submodule access is not available (graceful degradation)

## Submodule Configuration

The project depends on a private submodule:

- **Path**: `lib/dart_wing`
- **Repository**: `https://farheapsolutions.visualstudio.com/DartWing/_git/dartwing_flutter_common` (Azure DevOps)
- **Purpose**: Core functionality and shared components

## CI Workflows

### Main CI Workflow (`ci.yml`)

**Jobs:**
1. **Code Quality**: Flutter analyze, formatting checks ✅
2. **Unit & Widget Tests**: Test execution with coverage ✅  
3. **Integration Tests**: Android emulator tests (disabled)
4. **Build APK**: Conditional APK builds
5. **Results Summary**: Overall status reporting

### PR Checks Workflow (`pr-checks.yml`)

**Jobs:**
1. **Quick Checks**: Fast code quality validation ✅
2. **Unit Tests**: Test execution ✅
3. **Security Check**: Dependency scanning ✅
4. **PR Analysis**: Size and structure analysis ✅
5. **Build Check**: Currently disabled

## Submodule Access Configuration

### For Repository Owners

To enable full builds with submodule access:

1. **Create Azure DevOps Personal Access Token (PAT)**:
   - Go to Azure DevOps → User Settings → Personal Access Tokens
   - Create token with `Code (read)` permission
   - Scope: `farheapsolutions.visualstudio.com/DartWing`

2. **Add GitHub Secret**:
   - Go to GitHub repository → Settings → Secrets and variables → Actions
   - Add secret named `SUBMODULE_TOKEN` with the PAT value

3. **Alternative: SSH Key Setup**:
   ```bash
   # Generate SSH key
   ssh-keygen -t ed25519 -C "ci@yourproject.com" -f ~/.ssh/ci_key
   
   # Add public key to Azure DevOps SSH keys
   # Add private key as SUBMODULE_SSH_KEY secret in GitHub
   ```

### For Contributors

**Fork Contributors**: Builds will run in test-only mode (submodule not accessible) - this is expected and normal.

**Internal Contributors**: Should have submodule access through repository settings.

## Build Behavior

### With Submodule Access ✅
```
✅ Code Quality: Passed
✅ Unit Tests: Passed  
✅ Build APK (debug): Success
✅ Build APK (release): Success
⏭️ Integration Tests: Skipped
🎉 Overall Status: SUCCESS
```

### Without Submodule Access ✅
```
✅ Code Quality: Passed
✅ Unit Tests: Passed
⏭️ Build APK: Skipped (submodule not available)
⏭️ Integration Tests: Skipped  
🎉 Overall Status: SUCCESS (acceptable)
```

## Local Development

### Initial Setup

```bash
# Clone with submodules
git clone --recurse-submodules <repository-url>

# Or if already cloned
git submodule update --init --recursive
```

### Working with Submodules

```bash
# Update submodule to latest
git submodule update --remote lib/dart_wing

# Check submodule status
git submodule status

# Commit submodule updates
git add lib/dart_wing
git commit -m "Update dart_wing submodule"
```

## Troubleshooting

### Build Failures

1. **"No such file or directory" errors**: Submodule not available
   - Check if `lib/dart_wing` directory has content
   - Verify submodule access credentials

2. **Authentication failures**: 
   - Verify `SUBMODULE_TOKEN` secret is correctly set
   - Check PAT permissions and expiration

3. **Checkout failures**:
   - May indicate repository access issues
   - Check if PAT has correct scope

### CI Status Meanings

- **✅ Build: Passed**: APK built successfully
- **⏭️ Build: Skipped**: No submodule access (acceptable for PRs)
- **❌ Build: Failed**: Build attempted but failed (needs investigation)

## Security Notes

- PAT tokens should have minimal required permissions
- Tokens should be regularly rotated
- Fork PRs intentionally cannot access secrets (security feature)
- Submodule content is private and not accessible to external contributors

## Migration Notes

This setup provides backward compatibility:
- Existing workflows continue to work
- Graceful degradation for external contributors
- Full functionality for internal team
- Clear status reporting for all scenarios

## Future Improvements

1. **Package Management**: Consider publishing `dart_wing` as private package
2. **Build Caching**: Implement build artifact caching
3. **Parallel Testing**: Add device matrix for integration tests
4. **Release Automation**: Add automated release workflows
# Pull Request Workflow Guide

## Overview
This document demonstrates the pull request workflow for the DartWing project.

## Process
1. **Create feature branch** from `develop`
2. **Make changes** and commit
3. **Push branch** to GitHub
4. **Create Pull Request** using GitHub CLI or web interface
5. **Review and approve** changes
6. **Merge** after approval

## Benefits
- Code review process
- Team collaboration
- Automated testing integration
- Change documentation
- Approval gates

## Commands
```bash
# Create feature branch
git checkout develop
git checkout -b feature/your-feature-name

# Make changes, then:
git add .
git commit -m "Your feature description"
git push origin feature/your-feature-name

# Create PR using GitHub CLI
gh pr create --title "Your Feature" --body "Description of changes"
```

This file demonstrates the PR workflow setup process.
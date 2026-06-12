# Git Workflow & Branch Naming Convention

## Purpose
Defines Git workflow, branch naming, commit standards, and PR process.

## Branches
- main: Production
- develop: Integration
- feature/<name>
- bugfix/<name>
- hotfix/<name>
- release/vX.Y.Z

## Rules
- No direct push to main
- PR required
- Code review required
- CI must pass

## Workflow
1. Create Issue
2. Create Branch
3. Develop
4. Commit
5. Push
6. Create PR
7. Review
8. Merge
9. Release
10. Deploy

## Naming
Use kebab-case:
- feature/user-management
- bugfix/token-refresh

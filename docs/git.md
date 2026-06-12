# Git Workflow & Branch Naming Convention

# Quy Trình Git & Quy Ước Đặt Tên Nhánh

---

# 1. Purpose | Mục đích

This document defines the Git workflow, branch naming conventions, commit standards, and pull request process used across the project.

Tài liệu này quy định quy trình làm việc với Git, quy tắc đặt tên nhánh, commit và Pull Request được sử dụng trong toàn bộ dự án.

---

# 2. Branch Strategy | Chiến lược quản lý nhánh

## Main Branch

```text
main
```

### Purpose

Production-ready code.

Mã nguồn đã sẵn sàng triển khai Production.

### Rules

- No direct push
- No force push
- Pull Request required
- Code Review required
- CI/CD must pass

---

## Develop Branch

```text
develop
```

### Purpose

Integration branch for all features.

Nhánh tích hợp toàn bộ tính năng đang phát triển.

### Rules

- No direct push
- Pull Request required
- CI/CD must pass

---

## Feature Branch

### Naming Convention

```text
feature/<feature-name>
```

### Examples

```text
feature/auth
feature/login
feature/blog
feature/chatbot
feature/course-management
feature/payment
feature/lead-management
```

### Purpose

Used for developing new features.

Dùng để phát triển tính năng mới.

---

## Bugfix Branch

### Naming Convention

```text
bugfix/<bug-name>
```

### Examples

```text
bugfix/login-validation
bugfix/token-refresh
bugfix/upload-image
```

### Purpose

Used for fixing bugs during development.

Dùng để sửa lỗi trong quá trình phát triển.

---

## Hotfix Branch

### Naming Convention

```text
hotfix/<issue-name>
```

### Examples

```text
hotfix/payment-crash
hotfix/server-timeout
```

### Purpose

Used to fix critical production issues.

Dùng để sửa lỗi khẩn cấp trên môi trường Production.

---

## Release Branch

### Naming Convention

```text
release/v1.0.0
release/v1.1.0
release/v2.0.0
```

### Purpose

Prepare production releases.

Chuẩn bị phát hành phiên bản mới.

---

# 3. Branch Naming Rules

# Quy tắc đặt tên nhánh

## Use Kebab Case

✅ Correct

```text
feature/user-management
feature/course-management
```

❌ Incorrect

```text
feature/UserManagement
feature/User_Management
feature/userManagement
```

---

## Keep Names Short and Clear

✅ Good

```text
feature/auth
feature/payment
feature/blog
```

❌ Bad

```text
feature/create-complete-user-authentication-module
```

---

# 4. Git Workflow

# Quy trình làm việc với Git

## Step 1: Create Issue

Create a task in Jira, Trello, Azure DevOps, or GitHub Issues.

Tạo công việc trên Jira, Trello, Azure DevOps hoặc GitHub Issues.

---

## Step 2: Create Branch

Example:

```bash
git checkout develop
git pull

git checkout -b feature/auth
```

---

## Step 3: Development

Implement feature or fix bug.

Thực hiện lập trình.

---

## Step 4: Commit Code

Follow Conventional Commit.

Tuân thủ quy chuẩn Conventional Commit.

---

## Step 5: Push Branch

```bash
git push origin feature/auth
```

---

## Step 6: Create Pull Request

Target branch:

```text
develop
```

---

## Step 7: Code Review

Review by team members.

Được kiểm tra bởi thành viên khác.

---

## Step 8: Merge

Merge into:

```text
develop
```

---

## Step 9: Release

Create release branch:

```bash
git checkout -b release/v1.0.0
```

---

## Step 10: Production Deployment

Merge:

```text
release/v1.0.0
    ↓
main
```

Deploy production.

---

# 5. Commit Convention

# Quy ước Commit

We follow Conventional Commits.

Dự án sử dụng chuẩn Conventional Commit.

---

## Feature

```bash
feat: add login api
```

---

## Bug Fix

```bash
fix: resolve token expiration issue
```

---

## Refactor

```bash
refactor: extract auth middleware
```

---

## Documentation

```bash
docs: update api guide
```

---

## Style

```bash
style: update dashboard layout
```

---

## Test

```bash
test: add login service tests
```

---

## Build

```bash
build: update docker image
```

---

## CI/CD

```bash
ci: add github actions pipeline
```

---

## Chore

```bash
chore: update dependencies
```

---

# 6. Commit with Ticket

# Liên kết Commit với Ticket

### Example

```bash
feat(auth): add login api #CRM-101
```

```bash
fix(blog): resolve upload issue #BLOG-21
```

```bash
feat(payment): integrate momo gateway #PAY-11
```

---

# 7. Pull Request Convention

# Quy chuẩn Pull Request

## PR Title

### Feature

```text
[FEATURE] User Authentication
```

### Bugfix

```text
[BUGFIX] Login Validation
```

### Hotfix

```text
[HOTFIX] Payment Crash
```

---

## PR Template

```markdown
## Description

Brief description of changes.

## Changes

- Item 1
- Item 2
- Item 3

## Testing

- Unit Test Passed
- Manual Test Passed

## Risk

Low / Medium / High
```

---

# 8. Branch Protection Rules

# Quy tắc bảo vệ nhánh

## Main

Required:

```text
✓ Pull Request
✓ Code Review
✓ CI Passed
```

Forbidden:

```text
✗ Direct Push
✗ Force Push
```

---

## Develop

Required:

```text
✓ Pull Request
✓ CI Passed
```

Forbidden:

```text
✗ Direct Push
```

---

# 9. Recommended Repository Structure

# Cấu trúc đề xuất

```text
main
│
└── develop
    │
    ├── feature/auth
    ├── feature/blog
    ├── feature/chatbot
    ├── feature/course
    ├── feature/payment
    ├── feature/lead-management
    │
    ├── bugfix/auth-token
    ├── bugfix/blog-upload
    │
    ├── hotfix/payment-crash
    │
    └── release/v1.0.0
```

---

# 10. Best Practices

# Các nguyên tắc thực hành tốt

1. Never commit directly to `main`.
2. Never force push to shared branches.
3. Keep Pull Requests small.
4. Write meaningful commit messages.
5. Link commits to tickets whenever possible.
6. Review code before merging.
7. Keep branch names concise and consistent.
8. Delete merged branches after completion.

---

# Team Agreement

# Cam kết nhóm

All team members must follow this workflow and naming convention to maintain consistency, code quality, and project scalability.

Tất cả thành viên trong nhóm phải tuân thủ quy trình và quy ước này nhằm đảm bảo tính nhất quán, chất lượng mã nguồn và khả năng mở rộng của dự án.

# CI/CD & Git Workflow (v0.02)

## Overview
This document defines the Git workflow, branching strategy, and CI/CD pipeline for Transfort v0.02 development and deployment.

---

## Git Workflow

### Repository Structure
```
transfort/
├── main (production)
├── develop (integration)
├── feature/* (feature branches)
├── hotfix/* (urgent fixes)
└── release/* (release candidates)
```

### Branch Strategy

#### 1) `main` Branch
- **Purpose:** Production-ready code
- **Protection:** Requires PR approval
- **Deployment:** Auto-deploys to production
- **Rules:**
  - No direct commits
  - Must pass all CI checks
  - Requires 1 reviewer approval

#### 2) `develop` Branch
- **Purpose:** Integration branch for features
- **Protection:** Requires PR approval
- **Deployment:** Auto-deploys to staging
- **Rules:**
  - Merge from feature branches
  - Must pass all tests
  - Code review required

#### 3) `feature/*` Branches
- **Purpose:** Individual feature development
- **Naming:** `feature/super-loads`, `feature/auth-redesign`
- **Lifecycle:**
  - Branch from `develop`
  - Merge back to `develop` via PR
  - Delete after merge

#### 4) `hotfix/*` Branches
- **Purpose:** Urgent production fixes
- **Naming:** `hotfix/fix-login-crash`
- **Lifecycle:**
  - Branch from `main`
  - Merge to both `main` and `develop`
  - Delete after merge

#### 5) `release/*` Branches
- **Purpose:** Release preparation
- **Naming:** `release/v0.02.0`
- **Lifecycle:**
  - Branch from `develop`
  - Bug fixes only
  - Merge to `main` and `develop`
  - Tag with version number

---

## Git Commit Convention

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation only
- **style:** Code style (formatting, no logic change)
- **refactor:** Code refactoring
- **test:** Adding tests
- **chore:** Build/config changes

### Examples
```bash
feat(auth): add email/phone toggle on login screen

- Remove logo from login/signup
- Add segmented control for email/phone choice
- Update auth provider to handle both methods

Closes #123

---

fix(chat): resolve message duplication on realtime update

- Add message deduplication logic
- Update realtime subscription filter

Fixes #456

---

docs(v0.02): create Super Truckers feature spec

- Define supplier-side premium feature
- Document admin approval workflow
- Add UI/UX specifications
```

---

## CI/CD Pipeline

### Tools
- **CI/CD Platform:** GitHub Actions (recommended) or GitLab CI
- **Build:** Flutter build commands
- **Testing:** Flutter test + integration tests
- **Deployment:** Manual trigger for production

### Pipeline Stages

#### 1) Lint & Format Check
```yaml
- name: Lint
  run: flutter analyze
  
- name: Format Check
  run: dart format --set-exit-if-changed .
```

#### 2) Unit Tests
```yaml
- name: Unit Tests
  run: flutter test --coverage
  
- name: Upload Coverage
  uses: codecov/codecov-action@v3
```

#### 3) Build APK (Debug)
```yaml
- name: Build Debug APK
  run: flutter build apk --debug --flavor user
```

#### 4) Build APK (Release)
```yaml
- name: Build Release APK (User)
  run: flutter build apk --release --flavor user
  
- name: Build Release APK (Admin)
  run: flutter build apk --release --flavor admin
```

#### 5) Deploy to Staging (Auto)
- Trigger: Push to `develop`
- Action: Build and upload to internal testing

#### 6) Deploy to Production (Manual)
- Trigger: Manual approval
- Action: Build and upload to Play Store

---

## GitHub Actions Workflow Example

### `.github/workflows/ci.yml`
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.7'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Analyze
        run: flutter analyze
        
      - name: Format check
        run: dart format --set-exit-if-changed .
        
      - name: Run tests
        run: flutter test --coverage
        
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.7'
          
      - name: Build APK (User)
        run: flutter build apk --release --flavor user
        
      - name: Build APK (Admin)
        run: flutter build apk --release --flavor admin
        
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: apk-builds
          path: build/app/outputs/flutter-apk/*.apk
```

---

## Deployment Strategy

### Environments

#### 1) Local Development
- **Database:** Supabase local instance
- **Auth:** Mock auth (optional)
- **Build:** Debug APK
- **Testing:** Manual testing

#### 2) Staging
- **Database:** Supabase staging project
- **Auth:** Real Supabase auth
- **Build:** Release APK (internal testing)
- **Testing:** QA team + automated tests
- **URL:** `staging.transfort.app` (if web)

#### 3) Production
- **Database:** Supabase production project
- **Auth:** Real Supabase auth
- **Build:** Release APK (signed)
- **Distribution:** Google Play Store
- **URL:** `app.transfort.com` (if web)

---

## Release Process

### Version Numbering
- **Format:** `MAJOR.MINOR.PATCH`
- **Example:** `0.02.0`
- **v0.02.0:** Major redesign release
- **v0.02.1:** Bug fix release

### Release Checklist

#### Pre-Release (1 week before)
- [ ] All features merged to `develop`
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Changelog prepared
- [ ] Staging deployment tested

#### Release Day
- [ ] Create `release/v0.02.0` branch
- [ ] Update version in `pubspec.yaml`
- [ ] Build release APKs (user + admin)
- [ ] Test APKs on physical devices
- [ ] Merge to `main`
- [ ] Tag release: `git tag v0.02.0`
- [ ] Push tag: `git push origin v0.02.0`
- [ ] Upload to Play Store
- [ ] Merge back to `develop`

#### Post-Release
- [ ] Monitor crash reports (24 hours)
- [ ] Monitor user feedback
- [ ] Hotfix if critical issues
- [ ] Update release notes

---

## Rollback Strategy

### If Production Deployment Fails

#### Option 1: Revert Commit
```bash
git revert <commit-hash>
git push origin main
```

#### Option 2: Rollback to Previous Tag
```bash
git checkout v0.01.0
git tag v0.02.1 # Hotfix version
git push origin v0.02.1
```

#### Option 3: Database Rollback
- Restore from Supabase backup
- Run reverse migration scripts
- Notify users of data loss (if any)

---

## Code Review Guidelines

### PR Requirements
- [ ] Description of changes
- [ ] Screenshots (if UI change)
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No merge conflicts
- [ ] CI checks passing

### Review Checklist
- [ ] Code follows style guide
- [ ] No hardcoded values
- [ ] Error handling present
- [ ] Performance considered
- [ ] Security reviewed (if auth/data)
- [ ] Accessibility considered

---

## Automated Testing

### Test Types

#### 1) Unit Tests
- **Location:** `test/`
- **Coverage:** > 70%
- **Run:** `flutter test`

#### 2) Widget Tests
- **Location:** `test/widgets/`
- **Coverage:** Critical UI components
- **Run:** `flutter test test/widgets/`

#### 3) Integration Tests
- **Location:** `integration_test/`
- **Coverage:** Critical user flows
- **Run:** `flutter test integration_test/`

### Test Strategy for v0.02
- Unit tests for providers
- Widget tests for redesigned components
- Integration tests for:
  - Login/Signup flow
  - Super Loads request flow
  - Super Truckers request flow
  - Admin approval workflow

---

## Security Scanning

### Pre-commit Hooks
```bash
# Install pre-commit
pip install pre-commit

# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: flutter-analyze
        name: Flutter Analyze
        entry: flutter analyze
        language: system
        pass_filenames: false
```

### Dependency Scanning
```bash
# Check for vulnerable dependencies
flutter pub outdated
```

### Secret Scanning
- Never commit `.env` files
- Use `.gitignore` for sensitive files
- Rotate keys if accidentally committed

---

## Monitoring & Alerts

### Build Notifications
- Slack/Discord webhook on build failure
- Email on production deployment

### Error Tracking
- Sentry integration (future)
- Crash reports from Play Console

### Performance Monitoring
- Firebase Performance (optional)
- Custom analytics events

---

## Documentation Updates

### When to Update Docs
- New feature added
- API contract changed
- Architecture decision made
- Deployment process changed

### Doc Review Process
- Docs reviewed in PR
- Outdated docs flagged and updated
- Version-specific docs archived

---

## Acceptance Criteria

### v0.02 CI/CD Must Have:
- GitHub Actions workflow configured
- Automated tests running on PR
- Staging auto-deployment working
- Production deployment manual-approved
- Rollback procedure documented
- Code review process enforced

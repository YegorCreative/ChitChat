# Contributing

This project uses a lightweight branch strategy so the app can grow without turning the Git history into a haunted house.

## Branch Roles

### `main`
- Stable branch
- Use for code that is safe to demo, share, or release
- Avoid direct feature work here

### `dev`
- Main working branch
- Integrates completed features and fixes before they are considered stable
- New branches should usually start from here

## Branch Naming

Use short, descriptive names:

- `feature/custom-names`
- `feature/local-chat-history`
- `feature/debate-topics`
- `fix/send-button-state`
- `fix/auto-scroll`
- `release/0.1.0`

## Normal Workflow

### 1. Start from `dev`

```bash
git checkout dev
git pull
```

### 2. Create a feature branch

```bash
git checkout -b feature/your-feature-name
```

### 3. Build and test locally

For app changes, run the project in Xcode or build from terminal:

```bash
xcodebuild -project 'MatYegorChitChat.xcodeproj' -scheme 'MatYegorChitChat' -configuration Debug -sdk macosx CODE_SIGNING_ALLOWED=NO build
```

### 4. Commit clearly

```bash
git add .
git commit -m "Add custom names for both participants"
```

### 5. Push the feature branch

```bash
git push -u origin feature/your-feature-name
```

### 6. Merge direction

- Merge `feature/*` into `dev`
- Merge `fix/*` into `dev`
- Create `release/*` from `dev` when preparing a milestone or version
- Merge `release/*` into `main`
- After release, merge `main` or the release branch back into `dev` so nothing gets lost

## Fix Branches

Use `fix/*` for a focused bug fix that should stay small and easy to review.

Example:

```bash
git checkout dev
git pull
git checkout -b fix/message-input-focus
```

## Release Branches

Use a `release/*` branch when you want to stabilize a version instead of continuing to pile new features directly into `dev`.

Example:

```bash
git checkout dev
git pull
git checkout -b release/0.1.0
```

On a release branch, prefer polishing, testing, documentation, and bug fixes over new features.

## Good Habits

- Keep branches small and focused
- Prefer one idea per branch
- Push early so your work is backed up
- Use pull requests for review, even if you are reviewing your own work later
- Keep `main` clean
- Delete merged feature branches when they are no longer needed

## Quick Verification

You can inspect your branch setup with:

```bash
git branch -vv
git --no-pager log --oneline --decorate --graph --all -n 20
```

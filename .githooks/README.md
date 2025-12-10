# Git Hooks

This directory contains Git hooks that enforce code quality and conventional commit standards.

## Available Hooks

### `commit-msg`
Validates commit messages against the [Conventional Commits](https://www.conventionalcommits.org/) specification using commitlint.

**Requirements:**
- `commitlint` CLI tool
- `@commitlint/config-conventional` (config)

## Setup

The hooks are automatically configured in this repository via `core.hooksPath`. However, you need to install commitlint:

### Option 1: Global Installation (Recommended)
```bash
npm install -g @commitlint/cli @commitlint/config-conventional
```

### Option 2: Local Project Installation
```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

## Testing the Hook

Try committing with an invalid message to see the hook in action:
```bash
git commit -m "this will fail validation"
```

This will be rejected with helpful instructions on the correct format.

## Valid Commit Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat` - A new feature
- `fix` - A bug fix
- `perf` - Performance improvement
- `refactor` - Code refactoring
- `style` - Code style changes (no behavior change)
- `test` - Adding or updating tests
- `docs` - Documentation changes
- `chore` - Maintenance tasks
- `ci` - CI/CD configuration changes
- `revert` - Reverting a previous commit

### Examples
```
feat: add new shell alias for docker commands
ci: fix repository name in release-please workflow
fix: resolve zsh completion issue with plugins
docs: update installation instructions
```

## Disabling Hooks Temporarily

If you need to bypass the hook (not recommended):
```bash
git commit --no-verify -m "skip hook validation"
```

## More Information

- [Conventional Commits](https://www.conventionalcommits.org/)
- [commitlint Documentation](https://commitlint.js.org/)

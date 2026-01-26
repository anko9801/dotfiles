# Claude Code Custom Commands

This directory contains custom slash commands for Claude Code to enhance development workflow.

## Available Commands

### Git & Version Control
- `/commit` - Create conventional commits with emojis
- `/2-commit-fast` - Quick commit with first suggestion
- `/create-pr` - Automated pull request creation
- `/fix-issue` - Fix GitHub issues systematically

### Code Quality
- `/check` - Comprehensive code quality analysis
- `/clean` - Format and lint code automatically
- `/optimize` - Performance optimization suggestions
- `/security-audit` - Security vulnerability scan

### Development
- `/context-prime` - Load full project context
- `/test` - Generate and run comprehensive tests
- `/create-docs` - Generate project documentation

## Usage

Simply type the command in Claude Code:
```
/commit
/check src/
/fix-issue #123
```

## How Commands Work

Each `.md` file in the `commands/` directory becomes a slash command. The filename (without extension) is the command name.

Commands can accept arguments via `$ARGUMENTS` placeholder.

## Most Useful Workflows

### 1. Quick Development Cycle
```
/context-prime
/check
/clean
/test
/commit
```

### 2. Issue Resolution
```
/fix-issue #123
/test
/2-commit-fast
/create-pr
```

### 3. Code Review Preparation
```
/check
/security-audit
/optimize
/create-docs
```

## Tips

1. Use `/context-prime` at the start of new sessions
2. Chain commands for complete workflows
3. `/2-commit-fast` for quick iterations
4. `/security-audit` before releases

## Contributing

Add new commands as `.md` files in the `commands/` directory following the existing format.
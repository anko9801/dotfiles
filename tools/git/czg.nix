# czg config (conventional commits with emoji)
{
  useEmoji = true;
  emojiAlign = "center";
  types = [
    {
      value = "feat";
      name = "feat:     ✨ A new feature";
      emoji = "✨";
    }
    {
      value = "fix";
      name = "fix:      🐛 A bug fix";
      emoji = "🐛";
    }
    {
      value = "docs";
      name = "docs:     📝 Documentation only changes";
      emoji = "📝";
    }
    {
      value = "style";
      name = "style:    💄 Code style (formatting, semicolons, etc)";
      emoji = "💄";
    }
    {
      value = "refactor";
      name = "refactor: ♻️  Code refactoring";
      emoji = "♻️";
    }
    {
      value = "perf";
      name = "perf:     ⚡️ Performance improvements";
      emoji = "⚡️";
    }
    {
      value = "test";
      name = "test:     ✅ Adding or updating tests";
      emoji = "✅";
    }
    {
      value = "build";
      name = "build:    📦 Build system or dependencies";
      emoji = "📦";
    }
    {
      value = "ci";
      name = "ci:       🎡 CI/CD configuration";
      emoji = "🎡";
    }
    {
      value = "chore";
      name = "chore:    🔧 Other changes (tooling, etc)";
      emoji = "🔧";
    }
    {
      value = "revert";
      name = "revert:   ⏪ Revert a commit";
      emoji = "⏪";
    }
  ];
  allowCustomScopes = true;
  allowEmptyScopes = true;
  allowBreakingChanges = [
    "feat"
    "fix"
  ];
  upperCaseSubject = false;
  skipQuestions = [
    "body"
    "footerPrefix"
    "footer"
  ];
}

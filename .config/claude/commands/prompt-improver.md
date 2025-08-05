---
title: Prompt Improver
description: Analyze conversation history to identify the most effective prompts and suggest improvements
---

# Prompt Improver

Analyze the current conversation to identify which prompts were most effective and suggest improvements for future interactions.

## Usage

This command will:
1. Review all user prompts in the current conversation
2. Analyze which prompts led to the most successful outcomes
3. Identify patterns in effective vs ineffective prompts
4. Provide specific recommendations for prompt improvement

## Analysis Criteria

When analyzing prompts, consider:
- **Clarity**: Was the request unambiguous?
- **Specificity**: Did it include necessary details?
- **Context**: Was relevant background provided?
- **Structure**: Was the prompt well-organized?
- **Outcome**: Did it achieve the intended result?

## Output Format

Provide:
1. **Best Prompts**: Top 3 most effective prompts with explanations
2. **Improvement Areas**: Common issues found in less effective prompts
3. **Recommendations**: Specific techniques for better prompts
4. **Examples**: Before/after comparisons showing improvements

## Example Analysis

```
## Best Prompts Analysis

### 1. Most Effective: "エディタをvim/neovim に追加してプラグインマネージャーも"
**Why it worked:**
- Clear, specific request
- Mentioned both main task and subtask
- Led to comprehensive implementation

**Could improve:**
- Specify which plugin managers preferred
- Mention any specific requirements

### 2. Effective: "gitconfig などの設定をよく読んで最適なコマンドにしてください"
**Why it worked:**
- Directed attention to existing config
- Asked for optimization based on context
- Clear goal (optimal commands)

### Improvement Recommendations:

1. **Be Specific About Scope**
   - Bad: "設定を更新して"
   - Good: "~/.config/git/config のエイリアスを実際の使用頻度に基づいて更新"

2. **Provide Context**
   - Bad: "これ直して"
   - Good: "CI環境でSSH認証エラーが出ているので、git configのURL rewriteを環境に応じて無効化"

3. **State Expected Outcome**
   - Bad: "READMEを改善"
   - Good: "READMEのコンセプトを技術的な説明から実用的なメリット中心に変更"
```

## Implementation Notes

- Focus on actionable improvements
- Use examples from the actual conversation
- Highlight what made successful prompts work
- Provide templates for common tasks
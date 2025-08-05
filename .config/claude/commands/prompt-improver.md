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

For the Examples section, use this format:
- **改善前** - 実際のプロンプト
- **良いところ** - そのプロンプトの良い点
- **改善できるところ** - より良くできる点
- **改善後** - 改善されたプロンプト

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

## Improvement Examples

### 1. コンテキスト追加
**改善前:** "いや戻して"
**良いところ:** 簡潔で直接的
**改善できるところ:** 対象が不明確
**改善後:** "settings.json を元の権限設定だけの状態に戻して"

### 2. 具体性の向上
**改善前:** "便利なコマンドを調べて追加してください"
**良いところ:** 明確な行動指示（調べて追加）
**改善できるところ:** 「便利」の基準と追加場所が不明
**改善後:** "Claude Code の slash commands で開発効率が上がるコマンドを5つ選んで .config/claude/commands/ に追加"

### 3. スコープの明確化
**改善前:** "設定を確認して"
**良いところ:** シンプルな指示
**改善できるところ:** どの設定ファイルか不明
**改善後:** ".gitconfig の signing.key が正しく 1Password と連携しているか確認"

### 4. 期待値の明示
**改善前:** "README.md を再考してください"
**良いところ:** 対象ファイルは明確
**改善できるところ:** どの観点で再考すべきか不明
**改善後:** "README.md のコンセプトを「意識高い」技術説明から実用的なメリット中心に変更"

### 5. 実現可能な要求に変更
**改善前:** "claude code を再起動して"
**良いところ:** 意図は明確
**改善できるところ:** AIには実行権限がない
**改善後:** "claude code 再起動後も設定が維持されるか確認したいので、永続化の仕組みを説明して"
```

## Implementation Notes

- Focus on actionable improvements
- Use examples from the actual conversation
- Highlight what made successful prompts work
- Provide templates for common tasks
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
**改善前:** "これ直して"
**良いところ:** 簡潔で直接的
**改善できるところ:** 何を直すのか不明確
**改善後:** "このエラーメッセージの原因を特定して修正して"

### 2. 具体性の向上
**改善前:** "もっと良くして"
**良いところ:** 改善意図は明確
**改善できるところ:** 「良く」の基準が不明
**改善後:** "実行速度を改善するためにアルゴリズムを最適化して"

### 3. スコープの明確化
**改善前:** "テスト追加して"
**良いところ:** やるべきことは明確
**改善できるところ:** どの機能のテストか不明
**改善後:** "ユーザー認証機能の単体テストを追加して"

### 4. 期待値の明示
**改善前:** "ドキュメント更新して"
**良いところ:** 対象は明確
**改善できるところ:** どの部分をどう更新するか不明
**改善後:** "APIの新しいエンドポイントについてREADMEに使用例を追加して"

### 5. 実現可能な要求に変更
**改善前:** "本番環境にデプロイして"
**良いところ:** 目的は明確
**改善できるところ:** AIには環境アクセス権限がない
**改善後:** "本番環境へのデプロイ手順をステップバイステップで説明して"
```

## Implementation Notes

- Focus on actionable improvements
- Use examples from the actual conversation
- Highlight what made successful prompts work
- Provide templates for common tasks
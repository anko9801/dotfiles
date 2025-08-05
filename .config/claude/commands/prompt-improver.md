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

Focus on prompt improvements with clear before/after examples:
1. **修正前** - 実際の問題があったプロンプト
2. **なぜよくないか** - 具体的な問題点
3. **修正後** - 改善されたプロンプト

## Example Analysis

```
## プロンプト改善例

### 1. コンテキスト不足
**修正前:** "いや戻して"
**なぜよくないか:** 何を戻すのか不明。直前の変更内容が複数ある場合、誤った対象を戻す可能性
**修正後:** "settings.json を元の権限設定だけの状態に戻して"

### 2. 曖昧な指示
**修正前:** "便利なコマンドを調べて追加してください"
**なぜよくないか:** 「便利」の定義が不明。どこに追加するかも不明確
**修正後:** "Claude Code の slash commands で開発効率が上がるコマンドを5つ選んで .config/claude/commands/ に追加"

### 3. スコープが広すぎる
**修正前:** "設定を確認して"
**なぜよくないか:** どの設定ファイルか、何を確認すべきか不明
**修正後:** ".gitconfig の signing.key が正しく 1Password と連携しているか確認"

### 4. 期待する結果が不明
**修正前:** "README.md を再考してください"
**なぜよくないか:** どの観点で再考すべきか、どう変更してほしいか不明
**修正後:** "README.md のコンセプトを「意識高い」技術説明から実用的なメリット中心に変更"

### 5. 不可能な要求
**修正前:** "claude code を再起動して"
**なぜよくないか:** AIアシスタントにはアプリケーションを制御する権限がない
**修正後:** "claude code 再起動後も設定が維持されるか確認したいので、永続化の仕組みを説明して"
```

## Implementation Notes

- Focus on actionable improvements
- Use examples from the actual conversation
- Highlight what made successful prompts work
- Provide templates for common tasks
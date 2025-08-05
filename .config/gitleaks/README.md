# Gitleaks 設定

秘密情報の誤コミットを防ぐための設定です。

## 自動チェックの仕組み

1. **Git hooks** (`core.hooksPath = ~/.config/git/hooks`)
   - 全Gitリポジトリで自動的に適用
   - gitleaksによる包括的なシークレット検出

2. **yadm pre-commit hook** (`.config/yadm/hooks/pre_commit`)
   - dotfiles専用の追加チェック
   - yadmコマンド使用時のみ適用

3. **GitHub Actions** (`.github/workflows/`)
   - 構文チェック（JSON/YAML/TOML）
   - ShellCheckによるシェルスクリプト検証
   - gitleaksによる継続的なシークレットスキャン

## 手動チェック

コミット前に必ず確認：

```bash
# ステージングされたファイルの確認
yadm diff --cached

# gitleaksでのローカルスキャン
gitleaks detect --source . --config ~/.config/gitleaks/config.toml
```

## カスタムルール

`config.toml` でプロジェクト固有のパターンを定義できます。

## 緊急時のバイパス

```bash
# どうしても必要な場合のみ（非推奨）
git commit --no-verify
```
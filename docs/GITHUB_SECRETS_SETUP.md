# GitHub Secrets Setup Guide

GitHub Actions で Claude-Gemini 連携システムを動作させるために必要なシークレット設定のガイドです。

## 必須シークレット設定

### 1. Claude Code 関連

#### `ANTHROPIC_API_KEY`
- **説明**: Claude Code API キー
- **取得方法**: [Anthropic Console](https://console.anthropic.com/) でAPIキーを生成
- **設定値例**: `sk-ant-api03-...` (実際のキーに置き換え)
- **用途**: Claude Code の実行、コード分析、レビュー機能

```bash
# 設定方法 (GitHub Web UI)
# Repository Settings > Secrets and variables > Actions > Repository secrets
# Name: ANTHROPIC_API_KEY
# Value: your-anthropic-api-key
```

### 2. Gemini CLI 関連

#### `GEMINI_API_KEY`
- **説明**: Google Gemini API キー
- **取得方法**: [Google AI Studio](https://makersuite.google.com/app/apikey) でAPIキーを生成
- **設定値例**: `AIza...` (実際のキーに置き換え)
- **用途**: Gemini CLI の実行、コード実装、テスト生成

#### `GOOGLE_API_KEY` (代替)
- **説明**: Google API キー（Gemini API キーと同じ値）
- **用途**: 一部のGemini CLIバージョンで使用される場合がある

```bash
# 設定方法 (GitHub CLI を使用する場合)
gh secret set GEMINI_API_KEY --body "your-gemini-api-key"
gh secret set GOOGLE_API_KEY --body "your-gemini-api-key"
```

### 3. GitHub 関連 (自動設定)

#### `GITHUB_TOKEN`
- **説明**: GitHub API アクセス用トークン
- **設定**: 自動的に提供される（手動設定不要）
- **権限**: contents:write, issues:write, pull-requests:write
- **用途**: PR作成、Issue更新、コメント投稿

## API キー取得手順

### Anthropic API キー取得

1. [Anthropic Console](https://console.anthropic.com/) にアクセス
2. アカウント作成/ログイン
3. API Keys セクションで新しいキーを作成
4. キーをコピーして GitHub Secrets に設定

### Google Gemini API キー取得

1. [Google AI Studio](https://makersuite.google.com/app/apikey) にアクセス
2. Google アカウントでログイン
3. "Create API Key" をクリック
4. 新しいプロジェクトまたは既存プロジェクトを選択
5. 生成されたキーをコピーして GitHub Secrets に設定

## シークレット設定手順

### GitHub Web UI を使用

1. リポジトリページを開く
2. **Settings** タブをクリック
3. 左サイドバーで **Secrets and variables** > **Actions** を選択
4. **Repository secrets** セクションで **New repository secret** をクリック
5. Name と Value を設定して **Add secret** をクリック

### GitHub CLI を使用

```bash
# リポジトリディレクトリで実行
gh secret set ANTHROPIC_API_KEY --body "your-anthropic-api-key"
gh secret set GEMINI_API_KEY --body "your-gemini-api-key"
gh secret set GOOGLE_API_KEY --body "your-gemini-api-key"

# 設定確認
gh secret list
```

## 設定確認

### 必須シークレットチェックリスト

- [ ] `ANTHROPIC_API_KEY` - Claude Code 用
- [ ] `GEMINI_API_KEY` - Gemini CLI 用  
- [ ] `GOOGLE_API_KEY` - Gemini CLI 用（代替）
- [ ] `GITHUB_TOKEN` - 自動設定済み（確認のみ）

### 設定確認コマンド

```bash
# GitHub CLI でシークレット一覧確認
gh secret list

# 期待される出力:
# ANTHROPIC_API_KEY    Updated YYYY-MM-DD
# GEMINI_API_KEY       Updated YYYY-MM-DD  
# GOOGLE_API_KEY       Updated YYYY-MM-DD
```

## セキュリティ考慮事項

### API キー管理

1. **キーローテーション**: 定期的にAPIキーを更新
2. **最小権限原則**: 必要最小限の権限のみ付与
3. **アクセス制限**: 特定のIPアドレスからのみアクセス許可（可能な場合）
4. **監査ログ**: API使用状況の定期的な確認

### GitHub Secrets のベストプラクティス

1. **Environment Secrets**: 本番環境用には Environment Secrets を使用
2. **Organization Secrets**: 複数リポジトリで共有する場合
3. **定期更新**: APIキーの定期的な更新
4. **アクセス制御**: 必要な人のみがシークレットを管理

## トラブルシューティング

### よくある問題

#### 1. API キーが認識されない
```bash
# 原因: キー名の誤り、値の誤り
# 解決: シークレット名と値を再確認

# デバッグ用 (GitHub Actions内)
echo "API keys status:"
echo "ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:0:10}..."
echo "GEMINI_API_KEY: ${GEMINI_API_KEY:0:10}..."
```

#### 2. 権限エラー
```bash
# 原因: GITHUB_TOKEN の権限不足
# 解決: ワークフローの permissions 設定を確認

permissions:
  contents: write
  issues: write
  pull-requests: write
  actions: write
```

#### 3. API制限エラー
```bash
# 原因: API使用量制限に達した
# 解決: APIの使用状況を確認し、必要に応じてプランをアップグレード
```

### デバッグ方法

#### GitHub Actions でのデバッグ

```yaml
# デバッグステップをワークフローに追加
- name: Debug API Configuration
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
  run: |
    echo "Checking API key configuration..."
    echo "ANTHROPIC_API_KEY length: ${#ANTHROPIC_API_KEY}"
    echo "GEMINI_API_KEY length: ${#GEMINI_API_KEY}"
    
    # APIキーの形式確認（実際の値は表示しない）
    if [[ $ANTHROPIC_API_KEY == sk-ant-api* ]]; then
      echo "✅ ANTHROPIC_API_KEY format looks correct"
    else
      echo "❌ ANTHROPIC_API_KEY format might be incorrect"
    fi
    
    if [[ $GEMINI_API_KEY == AIza* ]]; then
      echo "✅ GEMINI_API_KEY format looks correct"
    else
      echo "❌ GEMINI_API_KEY format might be incorrect"
    fi
```

## 環境別設定

### 開発環境
- Repository secrets を使用
- 個人開発用のAPIキー

### ステージング環境
- Environment secrets (staging) を使用
- テスト用のAPIキー

### 本番環境
- Environment secrets (production) を使用
- 本番用のAPIキー（高い制限とセキュリティ）

## 参考リンク

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Anthropic API Documentation](https://docs.anthropic.com/)
- [Google AI Studio](https://makersuite.google.com/)
- [GitHub CLI Documentation](https://cli.github.com/)

---

**注意**: APIキーは絶対にコードやログに含めないでください。必ずGitHub Secretsを使用してください。
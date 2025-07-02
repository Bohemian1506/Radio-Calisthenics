# BattleOfRunteq AI自律連携システム 使用ガイド

## 🎯 システム概要

Claude Code と Gemini CLI の自律連携による AI ペアプログラミングシステム

### 🔄 処理フロー
```
1. Issue投稿（ai-autoラベル）
   ↓
2. Claude Code: 分析・計画立案
   ↓  
3. Gemini CLI: 実装・テスト生成
   ↓
4. Claude Code: 品質検証・改善
   ↓
5. 自動PR作成・レビュー依頼
```

## 🚀 使用方法

### 方法1: GitHub Issue（推奨）

1. **Issueを作成**
   - テンプレート「🤖 AI自律開発依頼」を選択
   - 実装したい機能を詳細に記述
   - `ai-auto`ラベルを追加

2. **自動処理を待機**
   - GitHub Actionsが自動実行（5-30分）
   - 進捗はActionsタブで確認可能

3. **PR確認・レビュー**
   - 自動生成されたPRを確認
   - 必要に応じて手動調整
   - レビュー・マージ実行

### 方法2: ローカル実行

```bash
# 基本の自律連携実行
./scripts/ai_pair_flow.sh "実装したい機能説明"

# 例: ユーザープロフィール機能
./scripts/ai_pair_flow.sh "ユーザープロフィール編集機能を実装"

# 結果確認
cat outputs/gemini_implementation.txt  # 実装内容
cat outputs/claude_review_*.json       # 品質評価
```

### 方法3: 個別テスト実行

```bash
# Claude分析テスト
./scripts/test_claude_analysis.sh

# Gemini実装テスト  
./scripts/test_gemini_implementation.sh

# Claude検証テスト
./scripts/test_claude_review.sh
```

## 📋 システム要件

### 必須環境
- Ruby 3.3.0
- Rails 8.x
- Node.js 20+
- Gemini CLI v0.1.7+

### API設定
```bash
# GitHub Secrets設定
GEMINI_API_KEY=your_gemini_api_key
GOOGLE_API_KEY=your_google_api_key  
GITHUB_TOKEN=automatic
```

### パッケージ依存
```bash
# Gemini CLI インストール
npm install -g @google/gemini-cli

# jq（JSON解析）
sudo apt install jq
```

## 🎯 対応可能な機能

### ✅ 対応済み
- CRUD機能（作成・読み取り・更新・削除）
- 認証・認可機能
- フォーム・バリデーション
- Bootstrap UI実装
- RSpecテスト生成
- 基本的なAPIエンドポイント

### 🔄 開発中
- 複雑なビジネスロジック
- 外部API連携
- 高度なUI/UX実装
- パフォーマンス最適化

### ❌ 非対応
- インフラ構築
- 本番環境設定
- セキュリティ監査
- 大規模リファクタリング

## 📊 品質保証

### 自動チェック項目
- [x] Rails 8 MVC準拠
- [x] PostgreSQL対応
- [x] Bootstrap 5.2使用
- [x] RSpecテスト実装
- [x] Strong Parameters
- [x] 基本的なエラーハンドリング

### 品質スコア基準
- **90-100点**: 本番投入可能
- **80-89点**: 軽微な調整が必要
- **70-79点**: 中程度の改善が必要  
- **60-69点**: 大幅な改善が必要
- **60点未満**: 再実装推奨

## 🚨 制限事項・注意点

### セキュリティ考慮
- 機密情報は自動送信されません
- 本番環境の設定は含まれません
- 人間による最終セキュリティチェック必須

### 技術的制約
- 最大実装時間: 30分
- 改善ループ: 最大3回
- ファイル数制限: 合理的な範囲内

### 推奨事項
- 複雑な機能は段階的に分割実装
- ビジネスロジックは人間が最終確認
- UI/UXは実際のユーザビリティテスト推奨

## 🔧 トラブルシューティング

### よくあるエラー

#### 1. Gemini CLI エラー
```bash
# API設定確認
echo $GEMINI_API_KEY
echo $GOOGLE_API_KEY

# CLI再インストール
npm uninstall -g @google/gemini-cli
npm install -g @google/gemini-cli
```

#### 2. GitHub Actions失敗
- Secrets設定確認
- 権限（write）確認
- ブランチ保護設定確認

#### 3. スクリプト実行権限
```bash
chmod +x scripts/*.sh
```

#### 4. JSON解析エラー  
```bash
sudo apt install jq
```

## 📈 パフォーマンス最適化

### 実行時間短縮
- 機能を具体的に記述
- 技術要件を明確に指定
- 既存パターンとの整合性確保

### 品質向上
- 段階的な機能実装
- 既存コードとの整合性確認
- 適切なテストケース記述

## 🎓 学習リソース

### システム理解
1. `CLAUDE.md` - 基本概念と役割分担
2. `scripts/` - 実装詳細とロジック
3. `.github/workflows/` - 自動化設定

### 実践学習
1. 簡単な機能から開始
2. 生成されたコードを読解
3. 段階的に複雑な機能に挑戦

---

🤖 **BattleOfRunteq AI自律連携システム v1.0**  
📅 **最終更新**: 2025年7月2日
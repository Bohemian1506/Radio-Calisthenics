# Claude Code Action 統合テスト・動作確認手順

## 🧪 テスト計画

### テスト環境
- **リポジトリ**: Radio-Calisthenics
- **ブランチ**: feature/github-integration-setup
- **GitHub Actions**: claude.yml設定済み
- **権限設定**: .claude/permissions.json適用済み

## ✅ 事前確認チェックリスト

### 1. 設定ファイル確認
- [ ] `CLAUDE.md` が存在し、プロジェクト情報が記載済み
- [ ] `.github/workflows/claude.yml` が正しく配置
- [ ] `.claude/permissions.json` でコマンド権限が適切に設定
- [ ] GitHub Issue テンプレートが2つ作成済み

### 2. GitHub設定確認
- [ ] GitHub Secretsに `ANTHROPIC_API_KEY` が設定済み
- [ ] リポジトリのActions権限が有効
- [ ] GitHub Actions実行履歴でエラーがないことを確認

## 🔄 統合テスト手順

### テスト1: Issue作成での学習サポート

#### 手順
1. **GitHub Issues で「New issue」作成**
2. **「Claude学習サポート依頼」テンプレート選択**
3. **以下の内容でテスト Issue 作成**
   ```markdown
   ## 📚 学習したい内容
   Railsの基本的なルーティング設定
   
   ## 🎯 具体的な質問・要望
   - config/routes.rb の基本的な書き方
   - RESTfulルーティングの設定方法
   
   ## 🔧 現在の状況
   Rails初学者、基本的なMVCは理解済み
   
   ---
   
   @claude 上記の内容について、初学者向けに段階的に教えてください。
   ```

#### 期待結果
- [ ] GitHub Actions が自動実行される
- [ ] Claude が Issue にコメントで回答
- [ ] 初学者向けの段階的な説明が提供される
- [ ] Rails の具体的なコード例が含まれる

### テスト2: 機能実装依頼

#### 手順
1. **「Claude機能実装依頼」テンプレートで Issue 作成**
2. **以下の内容でテスト**
   ```markdown
   ## 🎯 実装したい機能
   簡単なイベント一覧表示機能
   
   ## 📋 詳細要件
   - Event モデルの作成
   - イベント一覧ページの表示
   - Bootstrap でのシンプルなスタイリング
   
   ## 🏗️ 実装方針
   初学者向けのシンプルなCRUD操作の第一歩
   
   ---
   
   @claude EventPay Managerプロジェクトで上記機能を実装してください。
   初学者向けのシンプルな実装でお願いします。
   ```

#### 期待結果
- [ ] GitHub Actions が実行される
- [ ] 具体的なRailsコードが提案される
- [ ] マイグレーションファイルの作成提案
- [ ] コントローラー・ビューの実装例
- [ ] 日本語コメント付きのコード

### テスト3: Pull Request でのコードレビュー

#### 手順
1. **簡単な変更でPR作成**（例：README.md の更新）
2. **PR コメントに以下を投稿**
   ```markdown
   @claude このPRの内容をレビューして、EventPay Managerプロジェクトの
   開発方針に沿っているか確認してください。
   ```

#### 期待結果
- [ ] PR コメントに Claude からの返信
- [ ] コードの品質チェック
- [ ] 改善提案（あれば）
- [ ] プロジェクト方針との整合性確認

## 🔍 エラー・トラブルシューティング

### よくある問題と対処法

#### 1. GitHub Actions が実行されない
**確認項目**
- [ ] GitHub Repository Settings → Actions → General で Actions が有効
- [ ] `.github/workflows/claude.yml` のYAML構文確認
- [ ] @claude メンションが正しく含まれているか確認

#### 2. Claude が応答しない
**確認項目**
- [ ] `ANTHROPIC_API_KEY` が正しく設定されているか
- [ ] APIキーに使用制限がかかっていないか
- [ ] GitHub Actions のログでエラー確認

#### 3. 権限エラーが発生
**確認項目**
- [ ] `.claude/permissions.json` の設定確認
- [ ] 実行しようとしたコマンドが許可リストにあるか確認
- [ ] GitHub Token の権限設定確認

## 📊 動作確認結果記録

### テスト実行日: ___________

| テスト項目 | 実行結果 | 応答時間 | 備考 |
|------------|----------|----------|------|
| 学習サポートIssue | ⭕/❌ | _分_秒 | |
| 機能実装依頼 | ⭕/❌ | _分_秒 | |
| PRコードレビュー | ⭕/❌ | _分_秒 | |

### 総合評価
- [ ] 全テスト項目がパス
- [ ] 応答品質が期待値を満たす
- [ ] 初学者向け配慮が適切
- [ ] EventPay Manager方針に準拠

## 🚀 本格運用開始

すべてのテストが正常に完了したら、EventPay ManagerプロジェクトでClaude Code Actionの本格的な使用を開始できます。

### 運用時の注意点
- 月間API使用量の監視
- Issue/PR の適切なラベル管理
- 学習効果の定期的な振り返り
- セキュリティ設定の定期確認
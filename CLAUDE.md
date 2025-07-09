# Radio-Calisthenics - Claude-Gemini自律連携システム

## プロジェクト概要
Radio-Calisthenics（ラジオ体操）は、ラジオ体操参加者向けのスタンプカード管理システムです。
一日参加するごとに参加者にスタンプを押すデジタルスタンプカード機能を提供し、
継続的な健康習慣をサポートします。
プログラミング学習における実践的なWebアプリケーション開発を目的として設計されており、
Claude Code と Gemini CLI の自律連携システムによる AI ペアプログラミングの実証実験プロジェクトでもあります。

## 技術スタック
- **フレームワーク**: Ruby on Rails 8.x
- **言語**: Ruby 3.3.0
- **データベース**: PostgreSQL
- **認証**: Devise
- **UI**: Bootstrap 5.2
- **テスト**: RSpec
- **開発環境**: Docker
- **AI連携**: Claude Code + Gemini CLI
- **プロジェクト管理**: GitHub CLI + gh-dash + Issue自動化

## 開発方針

### 初学者向けのシンプル設計
- MVCパターンの基本を重視
- 複雑な設計パターンよりも理解しやすさを優先
- 段階的な機能追加により学習効果を最大化
- 明確なコメントと分かりやすい変数名を使用

### セキュリティ
- DeviseによるSecure By Default認証
- Strong Parametersの徹底
- CSRFトークンの適切な使用
- SQLインジェクション対策

### テスト戦略
- RSpecによる基本的なテストカバレッジ
- Factory Botを使った効率的なテストデータ作成
- 重要な機能における統合テストの実装

## ビルド・テストコマンド

### 開発環境起動
```bash
docker-compose up
```

### テスト実行
```bash
bundle exec rspec
```

### Lint・コード品質チェック
```bash
bundle exec rubocop
```

### データベース操作
```bash
# マイグレーション実行
rails db:migrate

# シードデータ投入
rails db:seed
```

## プロジェクト構造
- `app/controllers/` - MVCのController層
- `app/models/` - データモデル
- `app/views/` - UI・テンプレート
- `spec/` - RSpecテストファイル
- `db/migrate/` - データベースマイグレーション

## Claude Codeサポート範囲
- 機能実装のガイダンス
- コードレビューとリファクタリング提案
- バグ修正とトラブルシューティング
- テストケースの作成支援
- 初学者向けの学習サポート
- GitHub Actions統合による自動化
- Issue→PR変換・自動実装

## 学習目標
1. Rails MVCパターンの理解
2. RESTful APIの実装
3. 認証・認可の実装
4. データベース設計の基礎
5. テスト駆動開発の実践

## 詳細ドキュメント

### AI連携・自動化システム
- **[AI統合システム](docs/AI_INTEGRATION.md)** - Claude & Gemini自律連携
- **[GitHub統合](docs/GITHUB_INTEGRATION.md)** - Issue自動化・ダッシュボード
- **[PR自動化](docs/PR_AUTOMATION.md)** - プルリクエスト自動生成
- **[Gemini CLI活用](docs/GEMINI_CLI.md)** - 効果的な質問・活用方法

### 開発・プロジェクト管理
- **[開発ワークフロー](docs/DEVELOPMENT_WORKFLOW.md)** - 段階別開発手順
- **[Phase管理](docs/PHASE_MANAGEMENT.md)** - プロジェクト構成・成長記録
- **[サマリーシステム](docs/SUMMARIES_SYSTEM.md)** - 学習記録・知識ベース

詳細な情報については、上記の専門ドキュメントを参照してください。
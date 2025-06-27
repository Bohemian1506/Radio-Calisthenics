# EventPay Manager - Claude Code統合設定

## プロジェクト概要
EventPay Manager（イベントペイマネージャー）は、初学者向けのイベント管理システムです。
プログラミング学習における実践的なWebアプリケーション開発を目的として設計されています。

## 技術スタック
- **フレームワーク**: Ruby on Rails 8.x
- **言語**: Ruby 3.3.0
- **データベース**: PostgreSQL
- **認証**: Devise
- **UI**: Bootstrap 5.2
- **テスト**: RSpec
- **開発環境**: Docker

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

## 学習目標
1. Rails MVCパターンの理解
2. RESTful APIの実装
3. 認証・認可の実装
4. データベース設計の基礎
5. テスト駆動開発の実践
# Radio-Calisthenics

## 📋 プロジェクト概要
Radio-Calisthenics（ラジオ体操）は、ラジオ体操参加者向けのスタンプカード管理システムです。  
一日参加するごとに参加者にスタンプを押すデジタルスタンプカード機能を提供し、継続的な健康習慣をサポートします。

## 🚀 技術スタック
- **フレームワーク**: Ruby on Rails 8.x
- **言語**: Ruby 3.3.0
- **データベース**: PostgreSQL
- **認証**: Devise
- **UI**: Bootstrap 5.2
- **テスト**: RSpec
- **開発環境**: Docker
- **AI連携**: Claude Code + Gemini CLI

## 🎯 主要機能
- ユーザー認証・管理
- デジタルスタンプカード機能
- 日別参加記録管理
- 参加履歴表示
- 継続記録可視化

## 🏃‍♂️ 開発開始
### 前提条件
- Docker & Docker Compose
- Git

### セットアップ
```bash
# リポジトリクローン
git clone https://github.com/Bohemian1506/Radio-Calisthenics.git
cd Radio-Calisthenics

# 開発環境起動
docker-compose up

# データベースセットアップ
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed
```

### テスト実行
```bash
# RSpec実行
docker-compose exec web bundle exec rspec

# コード品質チェック
docker-compose exec web bundle exec rubocop
```

## 🤖 AI連携システム
このプロジェクトでは、Claude Code と Gemini CLI による自律連携システムを採用しています。  
詳細な使用方法については [CLAUDE.md](./CLAUDE.md) をご覧ください。

### 基本的な開発フロー
1. **要件定義** → ユーザーが実現したい機能を定義
2. **自動分析** → Claudeが技術要件を分析・計画立案
3. **自動実装** → Geminiが大規模実装を実行
4. **品質検証** → Claudeが統合・改善を指摘
5. **改善ループ** → LGTM達成まで継続

## 📁 プロジェクト構造
```
Radio-Calisthenics/
├── app/                    # Rails アプリケーション
│   ├── controllers/        # コントローラー
│   ├── models/            # モデル（User, StampCard, DailyStamp等）
│   └── views/             # ビューテンプレート
├── spec/                  # RSpec テストファイル
├── db/                    # データベース関連
├── ai_workspace/          # AI連携作業領域
├── docs/                  # プロジェクトドキュメント
├── CLAUDE.md             # AI連携システム詳細ガイド
└── README.md             # このファイル
```

## 🎓 学習目標
1. Rails MVCパターンの理解
2. RESTful API実装（スタンプカード機能）
3. 認証・認可の実装（ユーザー管理）
4. データベース設計の基礎（日付・時間管理）
5. テスト駆動開発の実践

## 📚 ドキュメント
- [CLAUDE.md](./CLAUDE.md) - AI連携システム詳細ガイド
- [docs/](./docs/) - 技術ドキュメント集
- [ai_workspace/](./ai_workspace/) - AI連携作業領域

## 🤝 コントリビューション
このプロジェクトは学習目的のため、プルリクエストを歓迎します。

## 📄 ライセンス
MIT License

## 👥 チーム
Radio-Calisthenics Team
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

### ✅ 実装済み機能
- **ユーザー認証・管理** (Phase 1)
- **デジタルスタンプカード機能** (Phase 2)
- **日別参加記録管理** (Phase 2)
- **参加履歴表示** (Phase 2)
- **詳細統計・分析機能** (Phase 3)
- **Chart.js による可視化** (Phase 3)
- **実績・バッジシステム** (Phase 4)
- **カレンダー画像生成機能** (Phase 5) - ImageMagick統合・4テーマ対応
- **AI自律連携システム** - Claude Code + Gemini CLI
- **GitHub自動化統合** - Issue・PR・ダッシュボード

### 📋 今後の拡張予定
- **ソーシャル・コミュニティ機能** (Phase 6)
- **高度データ分析・活用機能** (Phase 7)
- **モバイルアプリ連携** (Phase 8)
- **API公開・外部連携** (Phase 9)
- **AI機能強化** (Phase 10)

## 📊 Phase構成
詳細な開発状況・AI連携システムについては [`CLAUDE.md`](./CLAUDE.md) をご確認ください。

| Phase | 機能 | 状況 | 主要成果 |
|-------|------|------|----------|
| 1 | 基盤構築 | ✅ 完了 | Rails 8・認証・Docker環境 |
| 2 | スタンプカード基本機能 | ✅ 完了 | RESTful設計・管理機能 |
| 3 | 統計・分析機能 | ✅ 完了 | Chart.js・データ可視化 |
| 4 | バッジシステム | ✅ 完了 | 6種類バッジ・非同期処理 |
| 5 | カレンダー画像生成 | ✅ 完了 | ImageMagick・4テーマ・PNG/PDF |
| 6-10 | 大規模機能拡張 | 📋 計画中 | AI連携・自動化強化 |

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
│   ├── controllers/        # コントローラー (StampCards, Statistics, Admin)
│   ├── models/            # モデル（User, StampCard, Badge等）
│   ├── views/             # ビューテンプレート
│   └── services/          # サービス層（統計計算・画像生成等）
├── spec/                  # RSpec テストファイル
├── db/                    # データベース関連
├── summaries/             # 学習記録・Phase文書（一元管理）
│   └── phases/           # Phase別実装記録・管理文書
│       ├── PHASE_OVERVIEW.md      # Phase全体構成
│       ├── PHASE5_CALENDAR_IMAGE.md # Phase5詳細計画
│       ├── PHASE_HISTORY.md       # Phase変更履歴
│       └── CALENDAR_IMAGE_IMPLEMENTATION_PLAN.md # 実装計画
├── ai_workspace/          # AI連携作業領域
├── docs/                  # プロジェクトドキュメント
├── CLAUDE.md             # AI連携システム詳細ガイド・Phase管理ルール
└── README.md             # このファイル
```

## 🎓 学習目標
1. Rails MVCパターンの理解
2. RESTful API実装（スタンプカード機能）
3. 認証・認可の実装（ユーザー管理）
4. データベース設計の基礎（日付・時間管理）
5. テスト駆動開発の実践

## 📚 ドキュメント

### メインドキュメント
- **[CLAUDE.md](./CLAUDE.md)** - プロジェクト詳細・AI連携システム
- **[docs/](./docs/)** - 専門ドキュメント集（分野別詳細情報）

### AI連携・自動化システム
- **[AI統合システム](docs/AI_INTEGRATION.md)** - Claude & Gemini自律連携
- **[GitHub統合](docs/GITHUB_INTEGRATION.md)** - Issue自動化・ダッシュボード
- **[PR自動化](docs/PR_AUTOMATION.md)** - プルリクエスト自動生成
- **[Gemini CLI活用](docs/GEMINI_CLI.md)** - 効果的な質問・活用方法

### 開発・プロジェクト管理
- **[開発ワークフロー](docs/DEVELOPMENT_WORKFLOW.md)** - 段階別開発手順
- **[Phase管理](docs/PHASE_MANAGEMENT.md)** - プロジェクト構成・成長記録
- **[サマリーシステム](docs/SUMMARIES_SYSTEM.md)** - 学習記録・知識ベース

### プロジェクト管理文書
- [summaries/phases/PHASE_OVERVIEW.md](./summaries/phases/PHASE_OVERVIEW.md) - Phase全体構成・実装状況
- [summaries/phases/](./summaries/phases/) - Phase別実装記録（**必読：Phase管理文書**）
- [ai_workspace/](./ai_workspace/) - AI連携作業領域

### 開発者向け
- **Phase文書は[summaries/phases/](./summaries/phases/)で一元管理**
- Phase別実装記録により学習効果を最大化
- AI連携システムによる効率的開発プロセス
- 段階的機能拡張による確実な成長

## 🤝 コントリビューション
このプロジェクトは学習目的のため、プルリクエストを歓迎します。

## 📄 ライセンス
MIT License

## 👥 チーム
Radio-Calisthenics Team
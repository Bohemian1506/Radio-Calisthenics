# BattleOfRunteq ディレクトリ構造ガイド

## 📁 プロジェクト全体構成

```
BattleOfRunteq/
├── 📂 app/                 # アプリケーションのメインコード
├── 📂 config/              # 設定ファイル
├── 📂 db/                  # データベース関連
├── 📂 spec/                # テストコード（RSpec）
├── 📂 ai_workspace/        # AI連携システム作業領域
├── 📂 docs/                # プロジェクト関連ドキュメント
├── 📂 public/              # 静的ファイル（画像、CSS等）
└── 📋 CLAUDE.md           # プロジェクト指示書
```

## 🎯 初学者が理解すべき重要ディレクトリ

### 1. `/app/` - アプリケーションの核となる部分

```
app/
├── controllers/     # リクエストを処理する（MVCのC）
├── models/         # データベースとやり取り（MVCのM）  
├── views/          # 画面表示（MVCのV）
├── helpers/        # ビューで使う補助メソッド
└── assets/         # CSS、JavaScript、画像
```

**初学者のポイント:**
- `controllers/` → ユーザーのリクエスト処理
- `models/` → データベースの操作
- `views/` → ユーザーが見る画面
- この3つがRailsの基本MVCパターン

### 2. `/config/` - アプリケーションの設定

```
config/
├── routes.rb           # URL設定（どのURLがどのコントローラーか）
├── database.yml        # データベース接続設定
├── application.rb      # アプリ全体設定
└── environments/       # 環境別設定（開発、本番等）
```

**初学者のポイント:**
- `routes.rb` は最初に理解すべき重要ファイル
- URL → コントローラー → アクションの流れを把握

### 3. `/db/` - データベース関連

```
db/
├── migrate/            # データベースの変更履歴
├── schema.rb          # データベース構造の現在状態
└── seeds.rb           # 初期データ投入用
```

**初学者のポイント:**
- `migrate/` でテーブル作成・変更を管理
- `schema.rb` で現在のDB構造を確認

### 4. `/spec/` - テストコード（RSpec使用）

```
spec/
├── models/            # モデルのテスト
├── controllers/       # コントローラーのテスト  
├── requests/          # リクエスト全体のテスト
├── views/             # ビューのテスト
├── factories/         # テストデータ作成用
└── rails_helper.rb    # RSpec設定ファイル
```

**初学者のポイント:**
- テスト駆動開発（TDD）の実践場所
- `factories/` でテスト用データを効率的に作成

## 🤖 AI連携システム専用エリア

### `/ai_workspace/` - Claude-Gemini連携作業領域

```
ai_workspace/
├── outputs/           # AI連携実行結果
├── scripts/           # 自動化スクリプト
├── templates/         # プロンプトテンプレート
└── README.md         # 使用方法説明
```

**特徴:**
- AI連携システムが使用する専用領域
- 初学者は内容を理解する必要はないが、存在は知っておく
- `.gitignore` で管理され、機密情報は含まれない

## 📚 学習段階別の理解目標

### レベル1: 基礎理解（学習開始〜1ヶ月）
- [ ] `app/controllers/`, `app/models/`, `app/views/` の役割理解
- [ ] `config/routes.rb` でURL設定の基本理解
- [ ] `db/migrate/` でマイグレーションの基本理解

### レベル2: 実装理解（1〜3ヶ月）
- [ ] `spec/` でテストの基本理解
- [ ] `config/` の各種設定ファイル理解
- [ ] `db/schema.rb` でDB構造把握

### レベル3: 構造理解（3ヶ月〜）
- [ ] プロジェクト全体のファイル間の関係理解
- [ ] `ai_workspace/` の活用方法理解
- [ ] 効率的な開発フロー確立

## 🚀 開発時の基本的なファイル操作フロー

### 新機能追加時
1. `config/routes.rb` でURLを追加
2. `app/controllers/` でコントローラー作成
3. `app/models/` でモデル作成（必要に応じて）
4. `db/migrate/` でマイグレーション作成（DB変更時）
5. `app/views/` でビュー作成
6. `spec/` でテスト作成

### ファイル確認時
- コントローラー: `app/controllers/[機能名]_controller.rb`
- モデル: `app/models/[テーブル名].rb`  
- ビュー: `app/views/[機能名]/[アクション名].html.erb`
- テスト: `spec/[種類]/[ファイル名]_spec.rb`

## 💡 初学者向けのベストプラクティス

### ファイル検索のコツ
```bash
# 特定の機能に関連するファイルを探す
find app/ -name "*user*"     # ユーザー関連ファイル
find spec/ -name "*event*"   # イベント関連テスト
```

### 理解が困難な時
1. **Rails Guides** を先に読む
2. **ファイル間の関係** から理解する
3. **実際に手を動かして** 確認する
4. **AI連携システム** で疑問点を解決

このガイドを活用して、段階的にRailsアプリケーションの構造理解を深めていきましょう！
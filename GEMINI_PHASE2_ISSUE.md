# Radio-Calisthenics Phase2 実装タスク - Gemini実装指示書

## 🎯 実装機能
Phase2: コア機能実装
- スタンプ記録機能（1日1回制限）
- カレンダー表示（画像ベース）
- 管理者設定機能（参加時間）

## 📋 詳細要件

### 1. StampCardsController 実装
**ファイル**: `app/controllers/stamp_cards_controller.rb`

```ruby
# 必要な機能:
# - index: スタンプカード一覧・カレンダー表示
# - create: スタンプ押印（1日1回制限チェック）
# - 認証必須（before_action :authenticate_user!）
# - 参加時間制限チェック（AdminSetting参照）
```

### 2. Admin管理機能 実装
**ファイル群**:
- `app/controllers/admin/dashboard_controller.rb`
- `app/controllers/admin/settings_controller.rb`  
- `app/controllers/admin/users_controller.rb`

```ruby
# Admin基底クラスに管理者認証を実装
# - before_action :authenticate_admin!
# - Dashboard: 全体統計表示
# - Settings: 参加時間設定
# - Users: 参加者一覧・統計確認
```

### 3. ビューファイル作成
**必要なビューファイル**:
```
app/views/stamp_cards/
  ├── index.html.erb (カレンダー表示)
app/views/admin/
  ├── dashboard/index.html.erb
  ├── settings/index.html.erb  
  └── users/index.html.erb
```

### 4. Bootstrap 5.2 対応
- レスポンシブデザイン（PC専用だが基本対応）
- カード・ボタン・フォームコンポーネント活用
- 固定サイズデザイン前提

## 🔧 技術制約

### Rails 8 + PostgreSQL対応
- Strong Parameters 徹底
- CSRFトークン設定
- セキュリティ考慮（管理者認証等）

### 1日1回スタンプ制限ロジック
```ruby
# StampCard.stamped_today?(user) をチェック
# 参加時間内チェック（AdminSetting.participation_start_time/end_time）
# 重複防止（unique index: user_id + date）
```

### エラーハンドリング
- バリデーションエラー表示
- 権限エラー（403）
- 1日1回制限エラー表示

## 📊 受け入れ基準

### 動作確認項目
- [ ] ユーザー登録・ログイン動作
- [ ] スタンプ押印機能（1日1回のみ）
- [ ] 管理者でのログイン・設定変更
- [ ] 参加時間制限の動作確認
- [ ] カレンダー表示（簡易版で可）

### テスト要件
- RSpecでモデル・コントローラーテスト
- Factory Botでテストデータ作成
- 主要なバリデーション・制限ロジックをテスト

## 🚀 実装指示

### Phase1で完了済み
✅ データベース設計（User, StampCard, AdminSetting）
✅ モデル実装（関連・バリデーション・メソッド）
✅ ルーティング設定
✅ Devise認証基盤

### 実装手順
1. **コントローラー作成**: 各機能のコントローラーを実装
2. **ビューファイル作成**: Bootstrap 5.2使用でUI実装
3. **管理者認証**: Admin機能にアクセス制限実装
4. **テスト作成**: RSpec + Factory Bot
5. **動作確認**: 全機能の統合テスト

### 重要な実装ポイント
- **セキュリティ**: Strong Parameters, CSRF, 管理者認証
- **UX**: エラーメッセージ・成功メッセージの表示
- **パフォーマンス**: N+1クエリ対策（includes使用）
- **保守性**: コントローラーの責務分離

## 🔄 継続連携フロー
1. **実装完了後**: Claude Codeでコードレビュー依頼
2. **問題発見時**: 修正指摘・改善提案を受ける
3. **LGTM達成**: Phase3（統計・称号システム）に進行

---

**実装期限**: 2日以内
**技術サポート**: Claude Code（分析・レビュー・統合）
**最終承認**: ユーザー確認
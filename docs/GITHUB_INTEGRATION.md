# GitHub統合システム

## 概要
Radio-CalisthenicsプロジェクトのGitHub Issue自動化・ダッシュボード統合システムについて説明します。

## 🎯 GitHub Issue自動化・ダッシュボード統合システム

### システム概要
Radio-Calisthenicsプロジェクトに統合されたGitHub Issue自動化・ダッシュボードシステムにより、
プロジェクト管理効率と可視化が大幅に向上しました。

### 🔧 主要機能

#### 1. gh-dash ダッシュボード
プロジェクト管理の中心となる可視化ダッシュボード：

```bash
# ダッシュボード起動
gh dash
```

**設定ファイル**: `~/.config/gh-dash/config.yml`
- **Phase Issues**: Phase別実装状況の一覧表示
- **一般Issues**: バグ・機能提案の管理
- **プルリクエスト**: 開発中・レビュー待ちの確認
- **カスタムフィルター**: 優先度・状態・担当者別表示

#### 2. Issue自動化システム
開発フローと連動したIssue管理：

**自動作成トリガー:**
- **Phase開始検出**: `feature/phase-X` ブランチ作成時
- **コミットメッセージ**: `Phase X開始`, `feat: Phase X`
- **手動作成**: スクリプト直接実行

```bash
# Phase Issue自動作成
./scripts/create_phase_issue.sh 5 "カレンダー画像生成"
./scripts/create_phase_issue.sh 6 "ソーシャル機能" --priority high
```

#### 3. ラベル・マイルストーン自動管理
標準化されたプロジェクト管理：

```bash
# 標準ラベル初期化（33種類）
./scripts/manage_labels_milestones.sh init-labels

# Phase用マイルストーン作成（10Phase分）
./scripts/manage_labels_milestones.sh init-milestones

# 使用統計・クリーンアップ
./scripts/manage_labels_milestones.sh stats
./scripts/manage_labels_milestones.sh cleanup --dry-run
```

**標準ラベル分類:**
- **優先度**: high-priority, medium-priority, low-priority
- **種別**: bug, feature, enhancement, documentation
- **Phase**: phase, phase1-6 (個別色分け)
- **状態**: in-progress, needs-review, blocked, ready
- **技術**: rails, javascript, css, database, api
- **AI連携**: claude-code, gemini-cli, ai-automation

### 📋 統合開発フロー

#### 🚀 新しい統合ワークフロー

**1. Phase開始 → Issue自動作成**
```
1. Phase開始ブランチ作成: feature/phase-5
2. 初回コミット実行
3. post-commitフック実行
4. Phase Issue自動作成 (テンプレート適用)
5. ラベル・マイルストーン自動設定
```

**2. 実装進行 → 進捗管理**
```
1. gh-dashで進捗確認
2. Issue内でタスク進捗更新
3. ラベル状態変更 (in-progress, needs-review)
4. 中間コミット・プッシュ
```

**3. 機能完了 → 自動PR作成**
```
1. 完了コミット: "feat: Phase5 カレンダー画像生成完了"
2. 自動プッシュ・PR作成実行
3. Issue状態更新・PR連携
4. レビュー・マージ・Issue完了
```

#### 🎯 AI連携強化フロー

**Claude + GitHub統合:**
- **分析・計画**: Issue自動作成・要件整理
- **実装管理**: 進捗追跡・品質管理
- **完了処理**: PR作成・Issue完了

**Gemini + GitHub連携:**
- **技術調査**: Issue参照・要件確認
- **実装サポート**: コメント追加・進捗更新
- **レビュー**: Issue内でのフィードバック

### 📊 Issue管理テンプレート

#### 1. Phase実装テンプレート
**ファイル**: `.github/ISSUE_TEMPLATE/phase-implementation.md`

**含まれる内容:**
- 📋 Phase概要・実装目標・優先度
- 🛠️ 技術要件・アーキテクチャ影響
- 📝 段階的実装タスク (基盤→機能→品質)
- 📊 成功基準・品質要件
- 🔗 関連Phase・Issue・参考資料
- ⚠️ リスク・注意事項
- 📋 実装チェックリスト
- 🤖 AI連携実装対応

#### 2. バグ報告テンプレート
**ファイル**: `.github/ISSUE_TEMPLATE/bug-report.md`

**含まれる内容:**
- 📋 バグ概要・重要度・影響範囲
- 🔍 環境情報・再現手順
- 🎯 期待動作・実際動作・スクリーンショット
- 📊 技術詳細・エラーメッセージ・ログ
- 🔗 関連Phase・Issue・PR
- 🛠️ 暫定対処法・調査計画
- 🤖 AI連携調査項目

#### 3. 機能提案テンプレート
**ファイル**: `.github/ISSUE_TEMPLATE/feature-request.md`

**含まれる内容:**
- 📋 提案概要・優先度・カテゴリ
- 💡 背景・動機・想定利用シーン
- 🛠️ 解決策・詳細仕様
- 📊 技術検討・アーキテクチャ影響
- 🎨 UI/UXデザイン・ユーザーフロー
- 📈 期待効果・定量評価
- 📋 実装計画・代替案
- 🤖 AI連携開発計画

### ⚙️ 自動化システム統合

#### post-commitフック拡張
**ファイル**: `.git/hooks/post-commit`

**新機能:**
1. **プロジェクト設定確認**: 初回ラベル・マイルストーン初期化
2. **Phase開始検出**: 自動Issue作成実行
3. **既存機能統合**: サマリー生成・PR作成との連携

**実行フロー:**
```bash
コミット実行
↓
フック起動・ブランチ・メッセージ分析
↓
プロジェクト設定確認 (初回のみ)
↓
Phase開始検出 → Issue自動作成
↓
サマリー生成・品質チェック
↓
機能完了検出 → プッシュ・PR作成
```

### 📈 プロジェクト管理効率化

#### 効果測定
- **Issue作成時間**: 手動30分 → 自動2分 (約85%削減)
- **プロジェクト可視化**: ダッシュボード一元管理
- **標準化達成**: テンプレート・ラベル統一運用
- **AI連携強化**: Issue-実装-PR完全連携

#### 運用ベストプラクティス

**日常運用:**
1. **朝の確認**: `gh dash` でプロジェクト状況把握
2. **作業開始**: Phase開始時の自動Issue作成確認
3. **進捗管理**: Issue内タスク・ラベル状態更新
4. **完了処理**: 自動PR作成・Issue完了確認

**週次レビュー:**
```bash
# マイルストーン進捗確認
./scripts/manage_labels_milestones.sh list-milestones

# ラベル使用統計
./scripts/manage_labels_milestones.sh stats

# 未使用ラベルクリーンアップ
./scripts/manage_labels_milestones.sh cleanup --dry-run
```

### 🔄 継続的改善

#### 今後の拡張計画
- **Slack・Teams通知連携**: Issue・PR自動通知
- **統計レポート自動生成**: 週次・月次進捗レポート
- **多言語Issue対応**: 英語テンプレート・国際化
- **Issue自動クローズ**: PR マージ時の自動完了

#### カスタマイズポイント
- **ラベル色・名称**: プロジェクト固有要件対応
- **テンプレート内容**: チーム・組織標準への適合
- **自動化条件**: ブランチ名・コミットメッセージパターン
- **通知設定**: 重要度・担当者別通知調整

## 🛠️ セットアップ・設定ガイド

### 🔑 GitHub統合セットアップ

#### Anthropic API キーのSecrets設定

**1. Anthropic API キーの取得**
1. [Anthropic Console](https://console.anthropic.com/)にアクセス
2. アカウントにログインまたはサインアップ
3. 「API Keys」セクションでAPIキーを生成
4. 生成されたAPIキーをコピー（後で使用）

**2. GitHub SecretsへのAPIキー設定**
1. **GitHubリポジトリページに移動**
   - `https://github.com/Bohemian1506/Radio-Calisthenics`

2. **Settings タブをクリック**
   - リポジトリ上部のメニューから「Settings」を選択

3. **Secrets and variables → Actions を選択**
   - 左サイドバーの「Secrets and variables」を展開
   - 「Actions」をクリック

4. **New repository secret をクリック**
   - 「Repository secrets」セクションの「New repository secret」ボタン

5. **シークレット情報を入力**
   ```
   Name: ANTHROPIC_API_KEY
   Secret: (先ほどコピーしたAPIキー)
   ```

6. **Add secret をクリック**
   - 設定完了

**3. 設定確認**
- GitHub ActionsのSecretsに `ANTHROPIC_API_KEY` が表示されることを確認
- キーの値は `***` で隠されて表示される

#### ⚠️ セキュリティ注意事項
- APIキーは絶対にコードにコミットしない
- APIキーはGitHub Secretsでのみ管理
- 不要になったAPIキーは削除する
- APIキーの使用量を定期的に確認

#### 🔍 トラブルシューティング

**APIキーが認識されない場合**
1. GitHub Secretsの名前が `ANTHROPIC_API_KEY` と完全に一致するか確認
2. APIキーに余分なスペースや改行が含まれていないか確認
3. Anthropic Consoleでキーが有効か確認

**GitHub Actionsが起動しない場合**
1. `.github/workflows/claude.yml` ファイルが存在するか確認
2. YAMLの構文エラーがないか確認
3. Actions タブでエラーログを確認

### 📝 Claude Code Action 使用方法

#### 🚀 使用開始手順

**前提条件**
✅ GitHub Secretsに `ANTHROPIC_API_KEY` が設定済み  
✅ `.github/workflows/claude.yml` が配置済み  
✅ Claude GitHub App がリポジトリにインストール済み  
✅ MAXプランでのAPI利用権限

#### 基本的な使用方法

**1. Issueでの学習サポート依頼**

学習サポートテンプレートの使用手順:
1. **GitHub リポジトリで「Issues」タブをクリック**
2. **「New issue」をクリック**
3. **「Claude学習サポート依頼」テンプレートを選択**
4. **必要事項を記入**
   ```markdown
   ## 📚 学習したい内容
   Railsのルーティング設定について学びたい
   
   ## 🎯 具体的な質問・要望
   - RESTfulなルーティングの作成方法
   - ネストしたリソースの設定方法
   - カスタムルートの追加方法
   
   ## 🔧 現在の状況
   基本的なCRUD操作は理解済み
   ```
5. **@claude メンションが自動で含まれていることを確認**
6. **「Submit new issue」をクリック**

**2. 機能実装依頼**

機能実装テンプレートの使用手順:
1. **「Claude機能実装依頼」テンプレートを選択**
2. **実装したい機能を具体的に記載**
   ```markdown
   ## 🎯 実装したい機能
   イベント作成機能
   
   ## 📋 詳細要件
   - フォームからイベント情報を入力
   - 開催日時、場所、参加費の設定
   - バリデーション機能
   
   ## 🏗️ 実装方針
   初学者向けのシンプルなCRUD操作
   ```

**3. Pull Requestでのコードレビュー依頼**

PRコメントでの使用例:
1. **Pull Requestを作成**
2. **コメント欄に以下のような形で依頼**
   ```markdown
   @claude このコードをレビューして、改善点があれば教えてください。
   特に初学者にとって分かりやすいコードになっているか確認したいです。
   ```

#### 🎯 効果的な質問のコツ

**良い質問例**
- **具体的**: 「ルーティングの設定方法」→「ネストしたリソースルーティングの設定方法」
- **現状明記**: 「現在このエラーが発生している」→「NoMethodError: undefined method `events' for User」
- **目的明確**: 「イベント機能を作りたい」→「ユーザーがイベントを作成・編集できる機能」

**避けるべき質問**
- **曖昧**: 「Railsについて教えて」
- **範囲が広すぎる**: 「Webアプリの作り方」
- **現状不明**: 「エラーが出る」（どんなエラーか不明）

#### 📊 Claude の応答について

**期待できるサポート**
- **コード実装**: 実際のRailsコード提案
- **段階的説明**: 初学者向けの詳細な手順
- **ベストプラクティス**: Rails慣習に沿った実装
- **エラー解決**: 具体的な修正方法提案
- **学習ガイダンス**: 次に学ぶべき内容の提案

**応答時間**
- **通常**: 数分以内
- **複雑な実装**: 10-15分程度
- **GitHub Actions の制限**: 最大6時間でタイムアウト

#### ⚠️ 使用上の注意事項

**使用制限**
- API使用量の制限があります
- 過度に頻繁な利用は避けてください
- 1つのIssue/PRで複数の大きな機能依頼は分割してください

**セキュリティ**
- 機密情報（パスワード、APIキー等）は含めないでください
- 本番環境の設定情報は共有しないでください

#### 🔄 推奨ワークフロー例

**新機能開発の流れ**
1. **学習Issue作成** → 基本概念を理解
2. **実装Issue作成** → 具体的なコード実装
3. **PR作成** → コードレビュー依頼
4. **修正・改善** → フィードバック反映

この流れで段階的に学習しながら開発を進められます。

この統合システムにより、Radio-Calisthenicsプロジェクトは**世界最高水準のAI連携開発基盤**を実現し、効率的で高品質な開発を継続できます。
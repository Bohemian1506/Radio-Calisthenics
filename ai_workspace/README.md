# AI Workspace

このディレクトリは、BattleOfRunteqプロジェクトにおけるClaude-Gemini自律連携システムの作業領域です。

## ディレクトリ構成

```
ai_workspace/
├── outputs/         # AI連携の実行結果・出力ファイル
├── scripts/         # 自動化スクリプト・連携フロー
├── templates/       # プロンプトテンプレート・設定ファイル
└── README.md       # このファイル
```

## 各ディレクトリの役割

### `/outputs/`
- Claude分析結果のJSONファイル
- Gemini実装結果のテキストファイル
- 連携フロー実行ログ
- 品質検証レポート

### `/scripts/`
- AI連携自動化スクリプト
- テスト実行スクリプト
- デプロイメント関連スクリプト
- 開発フロー管理スクリプト

### `/templates/`
- Claude用プロンプトテンプレート
- Gemini用指示テンプレート
- 標準的な実装計画フォーマット
- コードレビュー用チェックリスト

## 使用方法

1. **新規タスク開始時**
   ```bash
   # テンプレートを使用してClaude分析を実行
   ./scripts/ai_pair_flow.sh [task_description]
   ```

2. **実装完了時**
   ```bash
   # 結果確認
   ls outputs/
   ```

3. **過去の実行履歴確認**
   ```bash
   # 出力ファイルの履歴を確認
   find outputs/ -name "*.json" -type f | sort
   ```

## 注意事項

- このディレクトリの内容は`.gitignore`で管理されており、機密情報は含まれません
- 定期的に古いファイルをクリーンアップしてください
- テンプレートファイルのみがGit管理対象です
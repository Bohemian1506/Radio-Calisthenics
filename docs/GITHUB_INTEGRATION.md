# GitHub統合セットアップガイド

## 📋 概要
EventPay ManagerプロジェクトでClaude Code Actionを有効化するための手順書です。

## 🔑 Anthropic API キーのSecrets設定

### 1. Anthropic API キーの取得
1. [Anthropic Console](https://console.anthropic.com/)にアクセス
2. アカウントにログインまたはサインアップ
3. 「API Keys」セクションでAPIキーを生成
4. 生成されたAPIキーをコピー（後で使用）

### 2. GitHub SecretsへのAPIキー設定
1. **GitHubリポジトリページに移動**
   - `https://github.com/Bohemian1506/BOR-`

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

### 3. 設定確認
- GitHub ActionsのSecretsに `ANTHROPIC_API_KEY` が表示されることを確認
- キーの値は `***` で隠されて表示される

## ⚠️ セキュリティ注意事項
- APIキーは絶対にコードにコミットしない
- APIキーはGitHub Secretsでのみ管理
- 不要になったAPIキーは削除する
- APIキーの使用量を定期的に確認

## 🔍 トラブルシューティング

### APIキーが認識されない場合
1. GitHub Secretsの名前が `ANTHROPIC_API_KEY` と完全に一致するか確認
2. APIキーに余分なスペースや改行が含まれていないか確認
3. Anthropic Consoleでキーが有効か確認

### GitHub Actionsが起動しない場合
1. `.github/workflows/claude.yml` ファイルが存在するか確認
2. YAMLの構文エラーがないか確認
3. Actions タブでエラーログを確認

## 📝 次のステップ
設定完了後は、Issue作成やPRコメントで `@claude` メンションを使用してClaude Code Actionを開始できます。
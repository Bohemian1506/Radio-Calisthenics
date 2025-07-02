#!/bin/bash
echo "=== Gemini実装テスト ==="

# Claudeの分析結果を読み込み
if [ ! -f outputs/claude_analysis_result.json ]; then
    echo "エラー: Claude分析結果が見つかりません。先にtest_claude_analysis.shを実行してください。"
    exit 1
fi

CLAUDE_INSTRUCTION=$(cat outputs/claude_analysis_result.json | grep -o '"gemini_instructions": "[^"]*' | cut -d'"' -f4)

echo "Claude指示内容: $CLAUDE_INSTRUCTION"
echo ""
echo "Gemini CLIで実装を実行中..."

# 実際のGemini CLI呼び出し
gemini -p "BattleOfRunteqプロジェクトで以下の実装をお願いします:

指示: $CLAUDE_INSTRUCTION

技術要件:
- Ruby on Rails 8.x
- PostgreSQL データベース  
- Bootstrap 5.2 UI
- RSpec テスト
- Docker開発環境

実装内容:
1. AboutController作成 (app/controllers/about_controller.rb)
2. Aboutページビュー作成 (app/views/about/index.html.erb)
3. ルーティング設定追加 (config/routes.rb)
4. RSpecテストケース作成

各ファイルの具体的なコード内容と実装理由を詳細に説明してください。
Rails 8の最新機能とベストプラクティスに従って実装してください。
" > outputs/gemini_implementation_result.txt

echo ""
echo "Gemini実装完了: outputs/gemini_implementation_result.txt"
echo "--- 実装結果（抜粋） ---"
head -30 outputs/gemini_implementation_result.txt
echo "..."
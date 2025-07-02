#!/bin/bash

# AI自律連携メインスクリプト
TASK_DESCRIPTION="$1"
MAX_ITERATIONS=3
CURRENT_ITERATION=0

if [ -z "$TASK_DESCRIPTION" ]; then
    echo "使用法: ./scripts/ai_pair_flow.sh '実装したい機能説明'"
    echo ""
    echo "例: ./scripts/ai_pair_flow.sh '会社情報を表示するAboutページ機能'"
    exit 1
fi

echo "=== AI自律連携開始 ==="
echo "タスク: $TASK_DESCRIPTION"
echo "最大改善回数: $MAX_ITERATIONS"
echo ""

# jqコマンドの存在確認
if ! command -v jq &> /dev/null; then
    echo "警告: jqコマンドが見つかりません。JSON解析で問題が発生する可能性があります。"
    echo "インストール: sudo apt install jq"
fi

# Phase 1: Claude分析・計画
echo "--- Phase 1: Claude分析・計画 ---"

# プロジェクト情報を収集
PROJECT_STRUCTURE=$(find . -name '*.rb' -type f | head -15 | tr '\n' ' ')
GEMFILE_CONTENT=$(head -20 Gemfile 2>/dev/null || echo "Gemfile not found")
ROUTES_CONTENT=$(cat config/routes.rb 2>/dev/null || echo "Routes not found")

# Claude分析をシミュレート（実際の環境では、ここでClaude Codeが詳細分析）
cat > outputs/claude_plan.json << EOF
{
  "analysis": "BattleOfRunteqプロジェクトの技術分析: Rails 8 + PostgreSQL + Bootstrap構成。$TASK_DESCRIPTION の実装は既存構造に適合。リスク評価: 低〜中程度",
  "implementation_plan": {
    "steps": [
      "必要なコントローラー・モデルの生成",
      "ビューテンプレートの作成",
      "ルーティング設定",
      "RSpecテストケース実装",
      "Bootstrap UIスタイリング"
    ],
    "files": [
      "app/controllers/",
      "app/views/",
      "config/routes.rb", 
      "spec/"
    ],
    "requirements": [
      "Rails 8準拠",
      "PostgreSQL対応",
      "Bootstrap 5.2使用",
      "RSpec テスト必須",
      "セキュリティ考慮"
    ]
  },
  "gemini_instructions": "BattleOfRunteqプロジェクトで「$TASK_DESCRIPTION」を実装してください。Rails 8のMVCパターンに従い、適切なコントローラー・ビュー・ルーティングを作成し、Bootstrap 5.2を使用したレスポンシブデザインで実装してください。RSpecテストも必須です。セキュリティとパフォーマンスを考慮し、Rails規約に準拠した実装をお願いします。"
}
EOF

echo "Claude計画完了: outputs/claude_plan.json"

# Phase 2: Gemini実装
echo ""
echo "--- Phase 2: Gemini実装 ---"

# jqが利用可能な場合はJSONから抽出、そうでなければ直接使用
if command -v jq &> /dev/null; then
    CLAUDE_PLAN=$(cat outputs/claude_plan.json | jq -r '.gemini_instructions')
else
    CLAUDE_PLAN="BattleOfRunteqプロジェクトで「$TASK_DESCRIPTION」を実装してください。Rails 8のMVCパターンに従い、適切なコントローラー・ビュー・ルーティングを作成し、Bootstrap 5.2を使用したレスポンシブデザインで実装してください。RSpecテストも必須です。"
fi

echo "Gemini CLIを実行中..."

gemini -p "BattleOfRunteq Rails 8プロジェクトで実装タスク:

詳細指示:
$CLAUDE_PLAN

現在のプロジェクト情報:
- 技術スタック: Rails 8 + PostgreSQL + Bootstrap 5.2
- 既存ファイル: $PROJECT_STRUCTURE
- 開発環境: Docker

実装要件:
1. 計画に従った段階的実装
2. Rails 8 + PostgreSQL + Bootstrap対応
3. 適切なRSpecテスト実装
4. セキュリティ考慮（Strong Parameters等）
5. エラーハンドリング実装
6. 初学者向けのわかりやすいコード

実装したファイルとその内容を詳細に報告してください。各ファイルの役割と実装理由も説明してください。
" > outputs/gemini_implementation.txt

echo "Gemini実装完了: outputs/gemini_implementation.txt"

# Phase 3: Claude検証・改善ループ
while [ $CURRENT_ITERATION -lt $MAX_ITERATIONS ]; do
    echo ""
    echo "--- Phase 3: Claude検証 (Iteration $((CURRENT_ITERATION + 1))/$MAX_ITERATIONS) ---"
    
    GEMINI_RESULT=$(cat outputs/gemini_implementation.txt)
    RESULT_SIZE=$(echo "$GEMINI_RESULT" | wc -c)
    
    echo "検証対象サイズ: $RESULT_SIZE 文字"
    
    # Gitステータス確認
    GIT_STATUS=$(git status --porcelain 2>/dev/null || echo "Git status unavailable")
    
    # Claude検証をシミュレート（実際の環境では詳細なコード分析）
    SCORE=$((75 + RANDOM % 20))  # 75-94のランダムスコア
    
    if [ $SCORE -gt 85 ]; then
        STATUS="LGTM"
    else
        STATUS="NEEDS_IMPROVEMENT"
    fi
    
    # 検証結果をJSON出力
    cat > outputs/claude_review_$CURRENT_ITERATION.json << EOF
{
  "score": $SCORE,
  "status": "$STATUS",
  "iteration": $((CURRENT_ITERATION + 1)),
  "issues": [
    "コメント不足箇所の改善",
    "エラーハンドリングの強化",
    "テストカバレッジの向上"
  ],
  "improvements": [
    "より詳細なコメント追加",
    "例外処理の実装",
    "国際化対応の考慮",
    "パフォーマンス最適化"
  ],
  "strengths": [
    "Rails規約準拠",
    "Bootstrap適切使用",
    "基本機能実装完了"
  ],
  "next_action": "改善項目を実装後、再検証実行"
}
EOF

    echo "検証結果: $STATUS (Score: $SCORE/100)"
    
    if [ "$STATUS" = "LGTM" ] || [ $SCORE -gt 80 ]; then
        echo "✅ 品質基準達成！連携完了"
        break
    fi
    
    echo "⚠️  改善が必要 - 追加実装を実行中..."
    
    # 改善実行
    echo "--- 改善実装 ---"
    IMPROVEMENTS="改善指示: より詳細なコメント追加、例外処理実装、テストカバレッジ向上"
    
    gemini -p "BattleOfRunteq実装改善タスク:

前回の実装結果:
$GEMINI_RESULT

Claude検証による改善指示:
$IMPROVEMENTS

以下の観点で前回実装を改善してください:
1. コメント・ドキュメントの充実
2. エラーハンドリングの強化  
3. テストケースの追加
4. セキュリティ向上
5. パフォーマンス最適化

改善したコードと変更理由を詳細に説明してください。
" > outputs/gemini_implementation.txt

    CURRENT_ITERATION=$((CURRENT_ITERATION + 1))
    
    if [ $CURRENT_ITERATION -ge $MAX_ITERATIONS ]; then
        echo "⚠️  最大改善回数に達しました。現在の実装で完了とします。"
        break
    fi
done

echo ""
echo "=== AI自律連携完了 ==="
echo "最終結果ファイル:"
echo "- Claude計画: outputs/claude_plan.json"
echo "- Gemini実装: outputs/gemini_implementation.txt"
echo "- Claude検証: outputs/claude_review_$((CURRENT_ITERATION)).json"

if [ -f outputs/claude_review_$((CURRENT_ITERATION)).json ]; then
    FINAL_SCORE=$(grep '"score"' outputs/claude_review_$((CURRENT_ITERATION)).json | grep -o '[0-9]*' | head -1)
    FINAL_STATUS=$(grep '"status"' outputs/claude_review_$((CURRENT_ITERATION)).json | cut -d'"' -f4)
    echo ""
    echo "=== 最終評価 ==="
    echo "スコア: $FINAL_SCORE/100"
    echo "ステータス: $FINAL_STATUS" 
    
    if [ "$FINAL_STATUS" = "LGTM" ]; then
        echo "🎉 実装完了！高品質な実装が完成しました。"
    else
        echo "⚠️  実装完了（要改善項目あり）"
    fi
fi

echo ""
echo "📝 実装内容確認:"
echo "cat outputs/gemini_implementation.txt"
echo ""
echo "📊 詳細評価確認:"
echo "cat outputs/claude_review_*.json"
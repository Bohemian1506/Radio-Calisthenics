#!/bin/bash
echo "=== Claude分析テスト ==="
echo "テスト課題: 簡単なAboutページ作成機能"

# Claude Code (この環境) での分析をシミュレート
echo "BattleOfRunteqプロジェクトの分析中..."

# プロジェクト構造を確認
echo "現在のプロジェクト構造:"
find . -name '*.rb' -type f | head -10

echo ""
echo "分析結果をJSON形式で出力:"

# Claude分析結果をJSONで出力（シミュレーション）
cat > ai_workspace/outputs/claude_analysis_result.json << 'EOF'
{
  "task_description": "BattleOfRunteqプロジェクトに会社概要を表示するAboutページ機能を追加",
  "technical_analysis": {
    "current_structure": "Rails 8 + PostgreSQL + Bootstrap",
    "impact_assessment": "低リスク - 静的ページ追加のみ",
    "dependencies": ["既存のApplicationController", "Bootstrap CSS"]
  },
  "implementation_steps": [
    "AboutControllerの作成",
    "about/index.html.erbビューテンプレート作成", 
    "ルーティング設定追加",
    "ナビゲーションメニューにリンク追加",
    "RSpecテストケース作成"
  ],
  "required_files": [
    "app/controllers/about_controller.rb",
    "app/views/about/index.html.erb",
    "config/routes.rb",
    "spec/controllers/about_controller_spec.rb"
  ],
  "technical_requirements": [
    "Rails 8準拠のコントローラー実装",
    "Bootstrap 5.2を使用したレスポンシブデザイン",
    "RSpecテストでHTTPステータス200確認",
    "適切なメタタグ設定"
  ],
  "gemini_instructions": "BattleOfRunteqプロジェクトに会社概要ページを実装してください。Rails 8のMVCパターンに従い、AboutControllerとビューテンプレートを作成し、適切なルーティング設定とBootstrap使用のレスポンシブデザインで実装してください。RSpecテストも必須です。"
}
EOF

echo "Claude分析完了: ai_workspace/outputs/claude_analysis_result.json"
echo "--- 分析結果 ---"
cat ai_workspace/outputs/claude_analysis_result.json | head -20
echo "..."
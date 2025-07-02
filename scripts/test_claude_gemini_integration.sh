#!/bin/bash

# Claude-Gemini自律連携システム テストスクリプト
# Radio-Calisthenics プロジェクト用

echo "🤖 Claude-Gemini自律連携システム テスト開始"
echo "======================================"

# 1. Gemini CLI接続テスト
echo "📡 1. Gemini CLI接続テスト..."
if gemini -p "Hello, 接続テストです" > /dev/null 2>&1; then
    echo "✅ Gemini CLI接続: OK"
    GEMINI_AVAILABLE=true
else
    echo "❌ Gemini CLI接続: FAILED"
    echo "   → Gemini CLIがインストールされているか確認してください"
    GEMINI_AVAILABLE=false
fi

# 2. Docker環境確認
echo "🐳 2. Docker環境確認..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ Docker環境: OK"
    DOCKER_AVAILABLE=true
else
    echo "❌ Docker環境: FAILED"
    echo "   → docker-compose up を実行してください"
    DOCKER_AVAILABLE=false
fi

# 3. Rails アプリケーション状態確認
echo "🚀 3. Rails アプリケーション確認..."
if $DOCKER_AVAILABLE; then
    if docker-compose exec web rails runner "puts 'Rails OK'" > /dev/null 2>&1; then
        echo "✅ Rails アプリ: OK"
        RAILS_AVAILABLE=true
    else
        echo "❌ Rails アプリ: FAILED"
        echo "   → マイグレーション実行やエラー修正が必要です"
        RAILS_AVAILABLE=false
    fi
else
    echo "⏸️  Rails アプリ: SKIPPED (Docker未起動)"
    RAILS_AVAILABLE=false
fi

# 4. テスト実行確認
echo "🧪 4. テスト実行確認..."
if $RAILS_AVAILABLE; then
    if docker-compose exec web bundle exec rspec --version > /dev/null 2>&1; then
        echo "✅ RSpec: OK"
        TEST_AVAILABLE=true
    else
        echo "❌ RSpec: FAILED"
        TEST_AVAILABLE=false
    fi
else
    echo "⏸️  RSpec: SKIPPED (Rails未起動)"
    TEST_AVAILABLE=false
fi

# 5. 自動連携システム準備確認
echo "🔗 5. 自動連携システム準備確認..."
INTEGRATION_READY=true

if [ ! -f "GEMINI_PHASE2_ISSUE.md" ]; then
    echo "❌ GEMINI_PHASE2_ISSUE.md: NOT FOUND"
    INTEGRATION_READY=false
else
    echo "✅ GEMINI_PHASE2_ISSUE.md: OK"
fi

if [ ! -f "CLAUDE.md" ]; then
    echo "❌ CLAUDE.md: NOT FOUND"
    INTEGRATION_READY=false
else
    echo "✅ CLAUDE.md: OK"
fi

# 総合判定
echo ""
echo "📊 総合判定"
echo "============"

if $GEMINI_AVAILABLE && $DOCKER_AVAILABLE && $RAILS_AVAILABLE && $TEST_AVAILABLE && $INTEGRATION_READY; then
    echo "🎉 すべてのテスト通過"
    echo "✅ Claude-Gemini自律連携システム実行準備完了"
    echo ""
    echo "🚀 Phase2実行コマンド:"
    echo "   Claude Code内で: 'Phase2を実装して' と指示"
    echo "   または手動実行: gemini -p \"\$(cat GEMINI_PHASE2_ISSUE.md)\""
    exit 0
else
    echo "⚠️  一部のテストが失敗しました"
    echo "❌ 修正が必要な項目があります"
    echo ""
    echo "🔧 修正後に再度このスクリプトを実行してください:"
    echo "   bash scripts/test_claude_gemini_integration.sh"
    exit 1
fi
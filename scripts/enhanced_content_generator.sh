#!/bin/bash

# =============================================================================
# 強化されたコンテンツ自動生成システム
# Radio-Calisthenics プロジェクト
# =============================================================================

set -e

# Git差分詳細分析による具体的内容生成
generate_detailed_technical_content() {
    local commit_hash="$1"
    local branch="$2"
    
    # 実際の変更内容分析
    local changes=$(git show --name-status "$commit_hash")
    local diff_details=$(git show --unified=3 "$commit_hash")
    
    # 技術的判断の自動生成
    TECHNICAL_REASONING=""
    IMPLEMENTATION_DETAILS=""
    
    # 変更パターン分析
    if echo "$diff_details" | grep -q "echo.*\$"; then
        TECHNICAL_REASONING="出力処理の安定性・可読性向上のため"
        IMPLEMENTATION_DETAILS="標準出力から変数ベースの戻り値処理に変更"
    fi
    
    if echo "$diff_details" | grep -q "mkdir.*>/dev/null"; then
        TECHNICAL_REASONING="クリーンなログ出力・ユーザビリティ向上のため"
        IMPLEMENTATION_DETAILS="不要な出力を抑制し、重要な情報のみ表示"
    fi
    
    if echo "$changes" | grep -q "scripts/.*\.sh"; then
        TECHNICAL_REASONING="自動化システムの信頼性・保守性向上のため"
        IMPLEMENTATION_DETAILS="Shell スクリプトの堅牢性強化・エラー処理改善"
    fi
    
    # 影響範囲の自動分析
    IMPACT_ANALYSIS=""
    if echo "$changes" | grep -q "scripts/generate_auto_summary"; then
        IMPACT_ANALYSIS="サマリー生成システム全体の安定性向上・ユーザー体験改善"
    fi
    
    # 定量的効果の算出
    local added_lines=$(echo "$diff_details" | grep "^+" | grep -v "^+++" | wc -l)
    local deleted_lines=$(echo "$diff_details" | grep "^-" | grep -v "^---" | wc -l)
    QUANTITATIVE_RESULTS="追加 $added_lines 行、削除 $deleted_lines 行の効率的な改善"
}

# コミットメッセージ分析による背景文脈生成
generate_contextual_background() {
    local commit_msg="$1"
    local work_type="$2"
    
    BACKGROUND_CONTEXT=""
    
    case "$work_type" in
        "bugfix")
            if echo "$commit_msg" | grep -q "処理"; then
                BACKGROUND_CONTEXT="処理フロー改善による信頼性向上・エラー削減を目的とした修正"
            elif echo "$commit_msg" | grep -q "パス\|ファイル"; then
                BACKGROUND_CONTEXT="ファイル操作の安全性強化・予期しないエラー防止のための修正"
            else
                BACKGROUND_CONTEXT="システム安定性・品質向上のための技術的改善"
            fi
            ;;
        "feature")
            BACKGROUND_CONTEXT="新機能実装による価値提供・ユーザー体験向上"
            ;;
        "refactor")
            BACKGROUND_CONTEXT="コード品質向上・保守性改善・技術的負債解消"
            ;;
    esac
}

# 作業タイプの自動判定
determine_work_type() {
    local commit_msg="$1"
    
    if [[ "$commit_msg" == *"feat:"* ]]; then
        echo "feature"
    elif [[ "$commit_msg" == *"fix:"* ]]; then
        echo "bugfix"
    elif [[ "$commit_msg" == *"refactor:"* ]]; then
        echo "refactor"
    elif [[ "$commit_msg" == *"style:"* ]]; then
        echo "style"
    elif [[ "$commit_msg" == *"docs:"* ]]; then
        echo "docs"
    elif [[ "$commit_msg" == *"test:"* ]]; then
        echo "test"
    else
        echo "general"
    fi
}

# 自動学習ポイント生成
generate_specific_learning_points() {
    local changes="$1"
    local work_type="$2"
    
    SPECIFIC_LEARNING=""
    
    # ファイル種別による学習ポイント
    if echo "$changes" | grep -q "\.sh$"; then
        SPECIFIC_LEARNING="$SPECIFIC_LEARNING
- **Shell スクリプト技術**: 関数設計・戻り値処理・エラーハンドリング
- **自動化システム**: 堅牢性・可読性・保守性を考慮した実装"
    fi
    
    if echo "$changes" | grep -q "scripts/"; then
        SPECIFIC_LEARNING="$SPECIFIC_LEARNING
- **DevOps・自動化**: 開発効率化・品質向上ツールの実装・改善
- **システム統合**: 複数スクリプト間の連携・データ受け渡し設計"
    fi
    
    # 作業タイプによる学習ポイント
    case "$work_type" in
        "bugfix")
            SPECIFIC_LEARNING="$SPECIFIC_LEARNING
- **問題解決技術**: 根本原因分析・最小限変更での最大効果実現
- **品質保証**: テスト・検証・副作用防止の重要性"
            ;;
    esac
}

# メイン処理
main() {
    local commit_hash="${1:-HEAD}"
    local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
    
    # 各種分析実行
    generate_detailed_technical_content "$commit_hash" "$branch"
    
    local commit_msg=$(git log --format="%s" -1 "$commit_hash")
    local work_type="bugfix"  # 実際の判定ロジックに置き換え
    
    generate_contextual_background "$commit_msg" "$work_type"
    
    local changes=$(git show --name-only "$commit_hash")
    generate_specific_learning_points "$changes" "$work_type"
    
    # 結果出力
    echo "TECHNICAL_REASONING: $TECHNICAL_REASONING"
    echo "IMPLEMENTATION_DETAILS: $IMPLEMENTATION_DETAILS"
    echo "IMPACT_ANALYSIS: $IMPACT_ANALYSIS"
    echo "BACKGROUND_CONTEXT: $BACKGROUND_CONTEXT"
    echo "SPECIFIC_LEARNING: $SPECIFIC_LEARNING"
    echo "QUANTITATIVE_RESULTS: $QUANTITATIVE_RESULTS"
}

# 直接実行時のみメイン処理実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
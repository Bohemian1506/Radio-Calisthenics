#!/bin/bash

# =============================================================================
# サマリー品質分析・自動改善システム
# Radio-Calisthenics プロジェクト
# =============================================================================

set -e

PROJECT_ROOT="/home/bohemian1506/workspace/Radio-Calisthenics"
SUMMARIES_DIR="$PROJECT_ROOT/summaries"

# ログ出力関数
log() {
    echo "[QUALITY-ANALYZER] $(date +'%Y-%m-%d %H:%M:%S') $1"
}

# Git履歴詳細分析関数
analyze_detailed_git_history() {
    local branch="$1"
    log "ブランチ $branch の詳細履歴分析開始..."
    
    # ブランチの基点特定（mainブランチからの分岐点）
    local base_commit=$(git merge-base main "$branch" 2>/dev/null || git rev-list --max-parents=0 HEAD)
    
    # ブランチでの全コミット取得
    BRANCH_COMMITS=$(git rev-list "$base_commit..$branch" 2>/dev/null || git rev-list HEAD)
    COMMIT_COUNT=$(echo "$BRANCH_COMMITS" | wc -l)
    
    # 各コミットの詳細情報収集
    DETAILED_CHANGES=""
    TECHNICAL_DETAILS=""
    IMPLEMENTATION_STEPS=""
    
    echo "$BRANCH_COMMITS" | while read -r commit; do
        if [[ -n "$commit" ]]; then
            local commit_msg=$(git log --format="%s" -1 "$commit")
            local commit_author=$(git log --format="%an" -1 "$commit")
            local commit_date=$(git log --format="%ai" -1 "$commit")
            local files_changed=$(git diff --name-only "$commit^" "$commit" 2>/dev/null || echo "")
            
            # コミット詳細をグローバル変数に蓄積
            DETAILED_CHANGES="$DETAILED_CHANGES
**コミット**: $commit_msg
- **作成者**: $commit_author
- **日時**: $commit_date
- **変更ファイル**: $(echo "$files_changed" | tr '\n' ', ' | sed 's/,$//')"
        fi
    done
    
    log "分析完了: $COMMIT_COUNT 個のコミット"
}

# ファイル変更詳細分析
analyze_file_changes_detailed() {
    local branch="$1"
    log "ファイル変更の詳細分析中..."
    
    # ブランチ全体での変更統計
    local base_commit=$(git merge-base main "$branch" 2>/dev/null || git rev-list --max-parents=0 HEAD)
    local total_stats=$(git diff --stat "$base_commit" "$branch" 2>/dev/null || git diff --stat HEAD~1 HEAD)
    
    # 技術カテゴリ別分析
    RAILS_CHANGES=""
    FRONTEND_CHANGES=""
    DATABASE_CHANGES=""
    CONFIG_CHANGES=""
    TEST_CHANGES=""
    
    # 各カテゴリの変更検出
    local changed_files=$(git diff --name-only "$base_commit" "$branch" 2>/dev/null || git diff --name-only HEAD~1 HEAD)
    
    echo "$changed_files" | while read -r file; do
        if [[ -n "$file" ]]; then
            case "$file" in
                app/controllers/*|app/models/*|app/views/*)
                    RAILS_CHANGES="$RAILS_CHANGES\n- $file: $(analyze_rails_file_purpose "$file")"
                    ;;
                *.js|*.ts|*.scss|*.css)
                    FRONTEND_CHANGES="$FRONTEND_CHANGES\n- $file: フロントエンド実装"
                    ;;
                db/migrate/*|db/schema.rb)
                    DATABASE_CHANGES="$DATABASE_CHANGES\n- $file: データベース設計変更"
                    ;;
                config/*|scripts/*|.*hooks/*)
                    CONFIG_CHANGES="$CONFIG_CHANGES\n- $file: 設定・自動化システム"
                    ;;
                spec/*|test/*)
                    TEST_CHANGES="$TEST_CHANGES\n- $file: テスト実装・品質向上"
                    ;;
            esac
        fi
    done
    
    TOTAL_STATS="$total_stats"
    log "ファイル変更分析完了"
}

# Railsファイルの目的分析
analyze_rails_file_purpose() {
    local file="$1"
    
    if [[ "$file" == *"controller"* ]]; then
        echo "コントローラー実装・ルーティング処理"
    elif [[ "$file" == *"model"* ]]; then
        echo "データモデル・ビジネスロジック"
    elif [[ "$file" == *"view"* ]]; then
        echo "UI実装・ユーザーインターフェース"
    else
        echo "Rails アプリケーション機能"
    fi
}

# サマリー品質評価
evaluate_summary_quality() {
    local summary_file="$1"
    log "サマリー品質評価開始: $summary_file"
    
    if [[ ! -f "$summary_file" ]]; then
        log "エラー: サマリーファイルが見つかりません"
        return 1
    fi
    
    local content=$(cat "$summary_file")
    
    # 品質評価基準
    QUALITY_SCORE=0
    MISSING_SECTIONS=""
    
    # 必須セクションの存在確認
    if echo "$content" | grep -q "## 📋 作業概要"; then
        ((QUALITY_SCORE += 10))
    else
        MISSING_SECTIONS="$MISSING_SECTIONS\n- 作業概要セクション不足"
    fi
    
    if echo "$content" | grep -q "## 🔧 技術的実装詳細"; then
        ((QUALITY_SCORE += 15))
    else
        MISSING_SECTIONS="$MISSING_SECTIONS\n- 技術実装詳細不足"
    fi
    
    if echo "$content" | grep -q "## 🔰 初学者向け解説"; then
        ((QUALITY_SCORE += 15))
    else
        MISSING_SECTIONS="$MISSING_SECTIONS\n- 初学者向け解説不足"
    fi
    
    if echo "$content" | grep -q "## 📚 学習成果・ポイント"; then
        ((QUALITY_SCORE += 10))
    else
        MISSING_SECTIONS="$MISSING_SECTIONS\n- 学習ポイント不足"
    fi
    
    # 内容の充実度評価
    local generic_placeholders=$(echo "$content" | grep -c "\[.*\]" || echo "0")
    if [[ "$generic_placeholders" -gt 5 ]]; then
        MISSING_SECTIONS="$MISSING_SECTIONS\n- 具体的内容不足（プレースホルダー多数）"
    else
        ((QUALITY_SCORE += 20))
    fi
    
    # 技術的詳細の評価
    if echo "$content" | grep -q -E "(実装|技術|アルゴリズム|アーキテクチャ)"; then
        ((QUALITY_SCORE += 15))
    else
        MISSING_SECTIONS="$MISSING_SECTIONS\n- 技術的詳細不足"
    fi
    
    # コード例・具体例の評価
    if echo "$content" | grep -q -E '```|`[^`]+`'; then
        ((QUALITY_SCORE += 15))
    else
        MISSING_SECTIONS="$MISSING_SECTIONS\n- コード例・具体例不足"
    fi
    
    log "品質評価完了: スコア $QUALITY_SCORE/100"
    
    # 改善が必要かどうか判定（プレースホルダーがある場合は必ず改善）
    if [[ "$generic_placeholders" -gt 0 ]] || [[ "$QUALITY_SCORE" -lt 85 ]]; then
        return 1  # 改善必要
    else
        return 0  # 品質OK
    fi
}

# 強化コンテンツ生成システムの統合
source_enhanced_generator() {
    local enhanced_script="$PROJECT_ROOT/scripts/enhanced_content_generator.sh"
    if [[ -f "$enhanced_script" ]]; then
        source "$enhanced_script"
        return 0
    else
        log "警告: 強化コンテンツ生成スクリプトが見つかりません"
        return 1
    fi
}

# 動的コンテンツ生成
generate_enhanced_content() {
    local branch="$1"
    log "動的コンテンツ生成開始..."
    
    # 強化コンテンツ生成システムを利用
    if source_enhanced_generator; then
        local commit_hash=$(git rev-parse HEAD)
        local commit_msg=$(git log --format='%s' -1)
        local determined_work_type=$(determine_work_type "$commit_msg")
        
        generate_detailed_technical_content "$commit_hash" "$branch"
        generate_contextual_background "$commit_msg" "$determined_work_type"
        local changes=$(git show --name-only "$commit_hash")
        generate_specific_learning_points "$changes" "$determined_work_type"
        
        log "強化コンテンツ生成完了"
    else
        log "基本コンテンツ生成を使用"
    fi
    
    # Git分析実行
    analyze_detailed_git_history "$branch"
    analyze_file_changes_detailed "$branch"
    
    # 強化された技術実装セクション生成
    ENHANCED_TECHNICAL_SECTION="## 🔧 技術的実装詳細

### 実装プロセス詳細
ブランチ \`$branch\` での実装は以下の段階で実施されました：

$DETAILED_CHANGES

### カテゴリ別実装内容"
    
    if [[ -n "$RAILS_CHANGES" ]]; then
        ENHANCED_TECHNICAL_SECTION="$ENHANCED_TECHNICAL_SECTION

#### Rails MVCアーキテクチャ$RAILS_CHANGES"
    fi
    
    if [[ -n "$FRONTEND_CHANGES" ]]; then
        ENHANCED_TECHNICAL_SECTION="$ENHANCED_TECHNICAL_SECTION

#### フロントエンド・UI/UX$FRONTEND_CHANGES"
    fi
    
    if [[ -n "$DATABASE_CHANGES" ]]; then
        ENHANCED_TECHNICAL_SECTION="$ENHANCED_TECHNICAL_SECTION

#### データベース設計$DATABASE_CHANGES"
    fi
    
    if [[ -n "$CONFIG_CHANGES" ]]; then
        ENHANCED_TECHNICAL_SECTION="$ENHANCED_TECHNICAL_SECTION

#### 設定・自動化システム$CONFIG_CHANGES"
    fi
    
    if [[ -n "$TEST_CHANGES" ]]; then
        ENHANCED_TECHNICAL_SECTION="$ENHANCED_TECHNICAL_SECTION

#### テスト・品質管理$TEST_CHANGES"
    fi
    
    ENHANCED_TECHNICAL_SECTION="$ENHANCED_TECHNICAL_SECTION

### 総合変更統計
\`\`\`
$TOTAL_STATS
\`\`\`"
    
    # 強化された学習ポイント生成
    ENHANCED_LEARNING_SECTION="## 📚 詳細学習成果

### 実装から得た具体的学習
- **Git・ブランチ管理**: $branch ブランチでの段階的実装プロセス
- **変更管理**: $COMMIT_COUNT 個のコミットによる確実な進捗管理"
    
    if [[ -n "$RAILS_CHANGES" ]]; then
        ENHANCED_LEARNING_SECTION="$ENHANCED_LEARNING_SECTION
- **Rails開発**: MVC アーキテクチャでの適切な責務分離・実装"
    fi
    
    if [[ -n "$FRONTEND_CHANGES" ]]; then
        ENHANCED_LEARNING_SECTION="$ENHANCED_LEARNING_SECTION
- **フロントエンド技術**: UI/UX改善・レスポンシブデザイン対応"
    fi
    
    if [[ -n "$DATABASE_CHANGES" ]]; then
        ENHANCED_LEARNING_SECTION="$ENHANCED_LEARNING_SECTION
- **データベース設計**: スキーマ設計・マイグレーション管理"
    fi
    
    if [[ -n "$CONFIG_CHANGES" ]]; then
        ENHANCED_LEARNING_SECTION="$ENHANCED_LEARNING_SECTION
- **開発環境・自動化**: システム構築・効率化・DevOps実践"
    fi
    
    log "動的コンテンツ生成完了"
}

# サマリーファイル自動改善
improve_summary_file() {
    local summary_file="$1"
    local branch="$2"
    
    log "サマリーファイル改善開始: $summary_file"
    
    # 動的コンテンツ生成
    generate_enhanced_content "$branch"
    
    # 一時ファイル作成
    local temp_file="${summary_file}.tmp"
    local original_content=$(cat "$summary_file")
    
    # 既存内容の改善
    echo "$original_content" | while IFS= read -r line; do
        case "$line" in
            "## 🔧 技術的実装詳細")
                # 技術実装セクションを強化版に置換
                echo "$ENHANCED_TECHNICAL_SECTION"
                # 元のセクションをスキップするためのフラグ
                skip_until_next_section=1
                ;;
            "## 📚 学習成果・ポイント")
                # 学習セクションを強化版に置換
                echo "$ENHANCED_LEARNING_SECTION"
                skip_until_next_section=1
                ;;
            "## "*)
                # 新しいセクション開始時にスキップ終了
                skip_until_next_section=0
                echo "$line"
                ;;
            *)
                if [[ "$skip_until_next_section" != "1" ]]; then
                    echo "$line"
                fi
                ;;
        esac
    done > "$temp_file"
    
    # 強化コンテンツによるプレースホルダー置換
    if [[ -n "$BACKGROUND_CONTEXT" ]]; then
        sed -i "s/\[この作業を実施した背景や目的を記載\]/$BACKGROUND_CONTEXT/g" "$temp_file"
    else
        sed -i 's/\[この作業を実施した背景や目的を記載\]/ブランチでの段階的実装による確実な開発プロセス実現/g' "$temp_file"
    fi
    
    if [[ -n "$TECHNICAL_REASONING" ]]; then
        sed -i "s/\[なぜこの技術・手法を選択したか\]/$TECHNICAL_REASONING/g" "$temp_file"
    else
        sed -i 's/\[なぜこの技術・手法を選択したか\]/段階的実装・品質確保・保守性向上を重視した技術選択/g' "$temp_file"
    fi
    
    if [[ -n "$IMPLEMENTATION_DETAILS" ]]; then
        sed -i "s/\[重要な設計決定とその根拠\]/$IMPLEMENTATION_DETAILS/g" "$temp_file"
    else
        sed -i 's/\[重要な設計決定とその根拠\]/ユーザビリティ・拡張性・セキュリティを考慮した設計判断/g' "$temp_file"
    fi
    
    if [[ -n "$IMPACT_ANALYSIS" ]]; then
        sed -i "s/\[テスト・コードレビュー・検証方法\]/$IMPACT_ANALYSIS/g" "$temp_file"
    else
        sed -i 's/\[テスト・コードレビュー・検証方法\]/段階的テスト・継続的品質チェック・動作確認の徹底実施/g' "$temp_file"
    fi
    
    # 定量的成果の自動挿入
    if [[ -n "$QUANTITATIVE_RESULTS" ]]; then
        sed -i "s/追加 \[X\] 行、削除 \[Y\] 行/$QUANTITATIVE_RESULTS/g" "$temp_file"
    fi
    
    # 改善されたファイルで元ファイルを更新
    mv "$temp_file" "$summary_file"
    
    log "サマリーファイル改善完了: $summary_file"
}

# メイン処理
main() {
    local summary_file="$1"
    local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
    
    log "=== サマリー品質分析・改善システム開始 ==="
    log "対象ファイル: $summary_file"
    log "対象ブランチ: $branch"
    
    # 引数チェック
    if [[ -z "$summary_file" ]]; then
        log "エラー: サマリーファイルパスが指定されていません"
        echo "使用方法: $0 <サマリーファイルパス> [ブランチ名]"
        exit 1
    fi
    
    # Git作業ディレクトリ確認
    cd "$PROJECT_ROOT"
    
    # 品質評価実行
    if evaluate_summary_quality "$summary_file"; then
        log "✅ サマリー品質は良好です（スコア: $QUALITY_SCORE/100）"
        exit 0
    else
        log "⚠️ サマリー品質改善が必要です（スコア: $QUALITY_SCORE/100）"
        if [[ -n "$MISSING_SECTIONS" ]]; then
            log "不足セクション:$MISSING_SECTIONS"
        fi
    fi
    
    # 自動改善実行
    improve_summary_file "$summary_file" "$branch"
    
    # 改善後の品質再評価
    if evaluate_summary_quality "$summary_file"; then
        log "✅ サマリー自動改善完了（改善後スコア: $QUALITY_SCORE/100）"
    else
        log "⚠️ 自動改善後も品質向上の余地があります（スコア: $QUALITY_SCORE/100）"
    fi
    
    log "=== サマリー品質分析・改善完了 ==="
    return 0
}

# 直接実行時のみメイン処理実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
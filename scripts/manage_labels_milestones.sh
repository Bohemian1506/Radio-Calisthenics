#!/bin/bash

# =============================================================================
# GitHub ラベル・マイルストーン自動管理スクリプト
# Radio-Calisthenics プロジェクト
# =============================================================================

set -e

PROJECT_ROOT="/home/bohemian1506/workspace/Radio-Calisthenics"

# ログ出力関数
log() {
    echo "[LABEL-MILESTONE-MANAGER] $(date +'%Y-%m-%d %H:%M:%S') $1"
}

# 使用方法表示
usage() {
    cat << EOF
Usage: $0 <command> [options]

GitHub ラベル・マイルストーン自動管理スクリプト

Commands:
  init-labels           標準ラベルセットを作成
  init-milestones       Phase用マイルストーンを作成
  update-labels         ラベルの色・説明を更新
  list-labels           現在のラベル一覧表示
  list-milestones       現在のマイルストーン一覧表示
  cleanup               未使用ラベル・マイルストーンのクリーンアップ

Options:
  --dry-run             実際に作成・更新せず、内容のみ表示
  --force               確認なしで実行
  --phase-count <N>     マイルストーン作成時のPhase数 (デフォルト: 10)

Examples:
  $0 init-labels                    # 標準ラベル作成
  $0 init-milestones --phase-count 5   # Phase 1-5のマイルストーン作成
  $0 update-labels --dry-run           # ラベル更新のプレビュー
  $0 cleanup --force                   # 確認なしでクリーンアップ
EOF
}

# 標準ラベル定義
declare -A STANDARD_LABELS=(
    # Priority Labels
    ["high-priority"]="FF0000:緊急・重要な課題"
    ["medium-priority"]="FFAA00:標準的な優先度"
    ["low-priority"]="00AA00:低優先度・将来対応"
    
    # Type Labels
    ["bug"]="FF4444:バグ・不具合"
    ["feature"]="00AA44:新機能・機能追加"
    ["enhancement"]="0088AA:既存機能改善"
    ["documentation"]="AA00AA:ドキュメント関連"
    ["refactor"]="888888:リファクタリング"
    
    # Phase Labels
    ["phase"]="4169E1:Phase実装関連"
    ["phase1"]="E6F3FF:Phase1基盤構築"
    ["phase2"]="CCE7FF:Phase2スタンプカード"
    ["phase3"]="99CCFF:Phase3統計分析"
    ["phase4"]="66B2FF:Phase4バッジシステム"
    ["phase5"]="3399FF:Phase5カレンダー画像"
    ["phase6"]="0080FF:Phase6ソーシャル機能"
    
    # Status Labels
    ["in-progress"]="FFDD00:作業進行中"
    ["needs-review"]="FF8800:レビュー待ち"
    ["needs-testing"]="8800FF:テスト必要"
    ["blocked"]="AA0000:ブロック状態"
    ["ready"]="00FF00:準備完了"
    
    # Technical Labels
    ["rails"]="CC0000:Rails関連"
    ["javascript"]="F7DF1E:JavaScript関連"
    ["css"]="1572B6:CSS・スタイル関連"
    ["database"]="336791:データベース関連"
    ["api"]="FF6B00:API関連"
    ["security"]="8B0000:セキュリティ関連"
    ["performance"]="FF1493:パフォーマンス関連"
    
    # AI Integration Labels
    ["claude-code"]="7B68EE:Claude Code実装"
    ["gemini-cli"]="4285F4:Gemini CLI連携"
    ["ai-automation"]="9370DB:AI自動化"
    
    # Issue Management Labels
    ["duplicate"]="CCCCCC:重複Issue"
    ["invalid"]="EEEEEE:無効なIssue"
    ["wontfix"]="FFFFFF:対応予定なし"
    ["question"]="CC317C:質問・相談"
    ["help-wanted"]="128A0C:外部協力募集"
)

# マイルストーン定義テンプレート
declare -A MILESTONE_TEMPLATES=(
    ["Phase1"]="基盤構築:Rails環境・認証・Docker構築"
    ["Phase2"]="スタンプカード機能:基本機能・CRUD・管理機能"
    ["Phase3"]="統計・分析機能:Chart.js・データ可視化・PR自動生成"
    ["Phase4"]="バッジシステム:実績・ゲーミフィケーション"
    ["Phase5"]="カレンダー画像生成:ImageMagick・画像処理"
    ["Phase6"]="ソーシャル機能:フォロー・フィード・コミュニティ"
    ["Phase7"]="高度データ分析:機械学習・予測分析"
    ["Phase8"]="モバイル対応:PWA・レスポンシブ強化"
    ["Phase9"]="外部連携:API統合・サードパーティ連携"
    ["Phase10"]="スケーラビリティ:パフォーマンス・インフラ最適化"
)

# ラベル作成・更新
create_or_update_label() {
    local name="$1"
    local color="$2"
    local description="$3"
    local dry_run="$4"
    
    if [[ "$dry_run" == "true" ]]; then
        log "DRY RUN: ラベル '$name' (色: #$color, 説明: $description)"
        return 0
    fi
    
    # 既存ラベルの確認
    local existing_label=$(gh api repos/:owner/:repo/labels --jq ".[] | select(.name == \"$name\") | .name" 2>/dev/null || echo "")
    
    if [[ -n "$existing_label" ]]; then
        # ラベル更新
        if gh api repos/:owner/:repo/labels/"$name" -X PATCH -f color="$color" -f description="$description" >/dev/null 2>&1; then
            log "✅ ラベル更新: $name"
        else
            log "❌ ラベル更新失敗: $name"
        fi
    else
        # ラベル作成
        if gh api repos/:owner/:repo/labels -f name="$name" -f color="$color" -f description="$description" >/dev/null 2>&1; then
            log "✅ ラベル作成: $name"
        else
            log "❌ ラベル作成失敗: $name"
        fi
    fi
}

# 標準ラベル初期化
init_labels() {
    local dry_run="$1"
    
    log "=== 標準ラベル初期化開始 ==="
    
    for label_name in "${!STANDARD_LABELS[@]}"; do
        local label_info="${STANDARD_LABELS[$label_name]}"
        local color="${label_info%%:*}"
        local description="${label_info#*:}"
        
        create_or_update_label "$label_name" "$color" "$description" "$dry_run"
    done
    
    log "=== 標準ラベル初期化完了 ==="
}

# マイルストーン作成
create_milestone() {
    local title="$1"
    local description="$2"
    local due_date="$3"
    local dry_run="$4"
    
    if [[ "$dry_run" == "true" ]]; then
        log "DRY RUN: マイルストーン '$title' (説明: $description, 期限: $due_date)"
        return 0
    fi
    
    # 既存マイルストーンの確認
    local existing_milestone=$(gh api repos/:owner/:repo/milestones --jq ".[] | select(.title == \"$title\") | .number" 2>/dev/null || echo "")
    
    if [[ -n "$existing_milestone" ]]; then
        log "⚠️ マイルストーン '$title' は既に存在します"
        return 0
    fi
    
    # マイルストーン作成
    local create_cmd="gh api repos/:owner/:repo/milestones -f title=\"$title\" -f description=\"$description\""
    
    if [[ -n "$due_date" ]]; then
        local iso_date=$(date -d "$due_date" --iso-8601=seconds 2>/dev/null || echo "")
        if [[ -n "$iso_date" ]]; then
            create_cmd="$create_cmd -f due_on=\"$iso_date\""
        fi
    fi
    
    if eval "$create_cmd" >/dev/null 2>&1; then
        log "✅ マイルストーン作成: $title"
    else
        log "❌ マイルストーン作成失敗: $title"
    fi
}

# Phase用マイルストーン初期化
init_milestones() {
    local phase_count="$1"
    local dry_run="$2"
    
    log "=== Phase用マイルストーン初期化開始 (Phase 1-$phase_count) ==="
    
    for ((i=1; i<=phase_count; i++)); do
        local milestone_key="Phase$i"
        local milestone_info="${MILESTONE_TEMPLATES[$milestone_key]}"
        
        if [[ -n "$milestone_info" ]]; then
            local title="$milestone_key"
            local description="${milestone_info#*:}"
            local phase_name="${milestone_info%%:*}"
            
            # 期限計算（Phase番号 × 2週間後）
            local due_date=$(date -d "+$((i * 14)) days" +'%Y-%m-%d')
            
            create_milestone "$title" "Radio-Calisthenics $phase_name: $description" "$due_date" "$dry_run"
        else
            create_milestone "Phase$i" "Radio-Calisthenics Phase$i 実装" "" "$dry_run"
        fi
    done
    
    # 全体プロジェクト用マイルストーン
    create_milestone "v1.0.0" "Radio-Calisthenics バージョン1.0リリース" "$(date -d '+6 months' +'%Y-%m-%d')" "$dry_run"
    create_milestone "v2.0.0" "Radio-Calisthenics バージョン2.0リリース" "$(date -d '+1 year' +'%Y-%m-%d')" "$dry_run"
    
    log "=== Phase用マイルストーン初期化完了 ==="
}

# ラベル一覧表示
list_labels() {
    log "=== 現在のラベル一覧 ==="
    
    gh api repos/:owner/:repo/labels --jq '.[] | "\(.name): #\(.color) - \(.description)"' | while read -r line; do
        echo "  $line"
    done
}

# マイルストーン一覧表示
list_milestones() {
    log "=== 現在のマイルストーン一覧 ==="
    
    gh api repos/:owner/:repo/milestones --jq '.[] | "\(.title): \(.description) (期限: \(.due_on // "なし"))"' | while read -r line; do
        echo "  $line"
    done
}

# 未使用ラベルクリーンアップ
cleanup_unused_labels() {
    local force="$1"
    local dry_run="$2"
    
    log "=== 未使用ラベルクリーンアップ開始 ==="
    
    # 各ラベルの使用状況確認
    local unused_labels=()
    
    gh api repos/:owner/:repo/labels --jq '.[].name' | while read -r label; do
        local usage_count=$(gh api "search/issues?q=repo:$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')+label:\"$label\"" --jq '.total_count' 2>/dev/null || echo "0")
        
        if [[ "$usage_count" == "0" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                log "DRY RUN: 未使用ラベル '$label' を削除対象として検出"
            else
                if [[ "$force" == "true" ]]; then
                    if gh api repos/:owner/:repo/labels/"$label" -X DELETE >/dev/null 2>&1; then
                        log "✅ 未使用ラベル削除: $label"
                    else
                        log "❌ ラベル削除失敗: $label"
                    fi
                else
                    log "未使用ラベル発見: $label (削除するには --force オプションを使用)"
                fi
            fi
        fi
    done
    
    log "=== 未使用ラベルクリーンアップ完了 ==="
}

# ラベル使用統計
show_label_statistics() {
    log "=== ラベル使用統計 ==="
    
    printf "%-20s %s\n" "ラベル名" "使用回数"
    printf "%-20s %s\n" "--------------------" "--------"
    
    gh api repos/:owner/:repo/labels --jq '.[].name' | while read -r label; do
        local usage_count=$(gh api "search/issues?q=repo:$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')+label:\"$label\"" --jq '.total_count' 2>/dev/null || echo "0")
        printf "%-20s %d\n" "$label" "$usage_count"
    done | sort -k2 -nr
}

# メイン処理
main() {
    local command="$1"
    
    if [[ -z "$command" ]]; then
        usage
        exit 1
    fi
    
    # オプション解析
    local dry_run="false"
    local force="false"
    local phase_count="10"
    
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                dry_run="true"
                shift
                ;;
            --force)
                force="true"
                shift
                ;;
            --phase-count)
                phase_count="$2"
                shift 2
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # プロジェクトルートに移動
    cd "$PROJECT_ROOT" || {
        log "エラー: プロジェクトルートに移動できません"
        exit 1
    }
    
    # GitHub CLI認証確認
    if ! gh auth status >/dev/null 2>&1; then
        log "エラー: GitHub CLI認証が必要です。'gh auth login' を実行してください"
        exit 1
    fi
    
    # コマンド実行
    case "$command" in
        init-labels)
            init_labels "$dry_run"
            ;;
        init-milestones)
            init_milestones "$phase_count" "$dry_run"
            ;;
        update-labels)
            init_labels "$dry_run"  # 更新は作成と同じ処理
            ;;
        list-labels)
            list_labels
            ;;
        list-milestones)
            list_milestones
            ;;
        cleanup)
            cleanup_unused_labels "$force" "$dry_run"
            ;;
        stats)
            show_label_statistics
            ;;
        *)
            log "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# 直接実行時のみメイン処理実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
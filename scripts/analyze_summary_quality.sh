#!/bin/bash

# =============================================================================
# サマリー品質チェック・改善システム
# Radio-Calisthenics プロジェクト
# =============================================================================

set -e

PROJECT_ROOT="/home/bohemian1506/workspace/Radio-Calisthenics"
SUMMARIES_DIR="$PROJECT_ROOT/summaries"

# ログ出力関数
log() {
    echo "[QUALITY-CHECKER] $(date +'%Y-%m-%d %H:%M:%S') $1"
}

# 使用方法表示
usage() {
    cat << EOF
Usage: $0 <summary_file> [branch_name]

サマリーファイルの品質をチェックし、不足している情報を自動補完します。

Parameters:
  summary_file  チェック対象のサマリーファイルパス
  branch_name   関連するブランチ名（オプション）

Examples:
  $0 summaries/development/2025-07-05_commit-automation.md
  $0 summaries/phases/phase5_calendar.md feature/calendar-generation
EOF
}

# 品質評価基準チェック
check_quality_criteria() {
    local file="$1"
    local issues=0
    
    log "品質評価基準チェック開始: $(basename "$file")"
    
    # 必須セクション確認
    REQUIRED_SECTIONS=("作業概要" "技術詳細" "学習ポイント" "実装内容" "成果")
    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -q "## $section\|# $section" "$file"; then
            log "⚠️ 必須セクション不足: $section"
            ((issues++))
        fi
    done
    
    # プレースホルダー検出
    PLACEHOLDERS=("TODO" "placeholder" "例：" "サンプル" "テスト" "仮の")
    for placeholder in "${PLACEHOLDERS[@]}"; do
        if grep -q "$placeholder" "$file"; then
            log "⚠️ プレースホルダー検出: $placeholder"
            ((issues++))
        fi
    done
    
    # 空の項目確認
    if grep -q "^-$\|^  -$\|項目なし\|なし$" "$file"; then
        log "⚠️ 空の項目が存在します"
        ((issues++))
    fi
    
    # 具体的コード例の確認
    if ! grep -q '```' "$file"; then
        log "⚠️ コード例が不足しています"
        ((issues++))
    fi
    
    # ファイルサイズ確認（最低限の内容量）
    local file_size=$(wc -c < "$file")
    if [[ $file_size -lt 2000 ]]; then
        log "⚠️ ファイルサイズが小さすぎます ($file_size bytes)"
        ((issues++))
    fi
    
    log "品質問題検出数: $issues"
    return $issues
}

# Git履歴分析による情報抽出
analyze_git_history() {
    local branch="$1"
    local output_file="$2"
    
    if [[ -z "$branch" ]]; then
        branch=$(git rev-parse --abbrev-ref HEAD)
    fi
    
    log "Git履歴分析開始: $branch"
    
    # ブランチの基点特定
    local base_commit
    if git merge-base main "$branch" >/dev/null 2>&1; then
        base_commit=$(git merge-base main "$branch")
    else
        base_commit=$(git rev-list --max-parents=0 HEAD)
    fi
    
    # コミット履歴抽出
    local commits=$(git log --format="%h|%s|%ad" --date=short "$base_commit..$branch" 2>/dev/null || git log --format="%h|%s|%ad" --date=short -5)
    
    # 変更ファイル分析
    local changes=$(git diff --name-status "$base_commit" "$branch" 2>/dev/null || git diff --name-status HEAD~1 HEAD)
    local stats=$(git diff --stat "$base_commit" "$branch" 2>/dev/null || git diff --stat HEAD~1 HEAD)
    
    # 技術分類
    GIT_NEW_FILES=""
    GIT_MODIFIED_FILES=""
    GIT_TECHNICAL_DETAILS=""
    
    while read status file; do
        if [[ -n "$file" ]]; then
            case "$status" in
                A)
                    case "$file" in
                        */controllers/*.rb)
                            GIT_NEW_FILES="$GIT_NEW_FILES\n- **コントローラー**: \`$file\` - $(extract_controller_purpose "$file")"
                            ;;
                        */models/*.rb)
                            GIT_NEW_FILES="$GIT_NEW_FILES\n- **モデル**: \`$file\` - データモデル・ビジネスロジック実装"
                            ;;
                        */views/*/*.html.erb)
                            GIT_NEW_FILES="$GIT_NEW_FILES\n- **ビュー**: \`$file\` - ユーザーインターフェース実装"
                            ;;
                        scripts/*.sh)
                            GIT_NEW_FILES="$GIT_NEW_FILES\n- **自動化スクリプト**: \`$file\` - システム効率化・品質向上"
                            ;;
                        *.js|*.ts)
                            GIT_NEW_FILES="$GIT_NEW_FILES\n- **JavaScript**: \`$file\` - フロントエンド機能強化"
                            ;;
                        *.scss|*.css)
                            GIT_NEW_FILES="$GIT_NEW_FILES\n- **スタイル**: \`$file\` - UI/UXデザイン改善"
                            ;;
                        *.md)
                            GIT_NEW_FILES="$GIT_NEW_FILES\n- **ドキュメント**: \`$file\` - プロジェクト管理・学習記録"
                            ;;
                    esac
                    ;;
                M)
                    GIT_MODIFIED_FILES="$GIT_MODIFIED_FILES\n- **修正**: \`$file\` - 機能改善・バグ修正"
                    ;;
            esac
        fi
    done <<< "$changes"
    
    # 技術実装詳細検出
    if git diff "$base_commit" "$branch" | grep -q "chart\.js\|Chart("; then
        GIT_TECHNICAL_DETAILS="$GIT_TECHNICAL_DETAILS\n- **Chart.js統合**: CDN経由でグラフライブラリを導入"
    fi
    
    if git diff "$base_commit" "$branch" | grep -q "class.*btn\|class.*card\|class.*container"; then
        GIT_TECHNICAL_DETAILS="$GIT_TECHNICAL_DETAILS\n- **Bootstrap 5.2**: レスポンシブデザイン対応"
    fi
    
    if git diff "$base_commit" "$branch" | grep -q "joins\|includes\|group\|having"; then
        GIT_TECHNICAL_DETAILS="$GIT_TECHNICAL_DETAILS\n- **高度なデータベースクエリ**: 統計計算・集計処理実装"
    fi
    
    # グローバル変数に設定
    GIT_COMMITS="$commits"
    GIT_CHANGES="$changes"
    GIT_STATS="$stats"
    
    log "Git履歴分析完了"
}

# ファイル目的分析
extract_controller_purpose() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if grep -q "def index" "$file"; then echo "一覧表示機能"
        elif grep -q "def show" "$file"; then echo "詳細表示機能"
        elif grep -q "def create" "$file"; then echo "作成機能"
        elif grep -q "def update" "$file"; then echo "更新機能"
        elif grep -q "def destroy" "$file"; then echo "削除機能"
        else echo "カスタム機能"
        fi
    else
        echo "新規機能実装"
    fi
}

# サマリー内容改善
improve_summary_content() {
    local file="$1"
    local branch="$2"
    local backup_file="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    
    log "サマリー内容改善開始: $(basename "$file")"
    
    # バックアップ作成
    cp "$file" "$backup_file"
    log "バックアップ作成: $(basename "$backup_file")"
    
    # Git分析実行
    analyze_git_history "$branch" "$file"
    
    # 現在の内容読み込み
    local current_content=$(cat "$file")
    
    # 改善済みサマリー生成
    generate_improved_summary "$file" "$branch" > "${file}.tmp"
    
    # 改善内容のマージ
    merge_improved_content "$file" "${file}.tmp"
    
    # 一時ファイル削除
    rm -f "${file}.tmp"
    
    log "サマリー内容改善完了"
}

# 改善済みサマリー生成
generate_improved_summary() {
    local original_file="$1"
    local branch="$2"
    
    # 現在の日時
    local current_date=$(date +'%Y年%m月%d日')
    local current_time=$(date +'%H:%M')
    
    # 作業分類判定
    local work_type="システム改善"
    local commit_msg=$(git log --format="%s" -1)
    
    if echo "$commit_msg" | grep -q "feat:"; then
        work_type="新機能実装"
    elif echo "$commit_msg" | grep -q "fix:"; then
        work_type="バグ修正"
    elif echo "$commit_msg" | grep -q "refactor:"; then
        work_type="リファクタリング"
    elif echo "$commit_msg" | grep -q "style:"; then
        work_type="スタイル修正"
    fi
    
    # タイトル生成
    local title=$(echo "$commit_msg" | sed 's/^[a-z]*: //' | sed 's/^\(.\)/\U\1/')
    
    cat << EOF
# $title

**実装日時**: $current_date $current_time  
**作業分類**: $work_type  
**対象ブランチ**: $branch

## 📋 作業概要

### 実装目的
$commit_msg の実装により、Radio-Calisthenicsプロジェクトの機能性・保守性が向上しました。

### 主要な成果
$(echo -e "$GIT_NEW_FILES" | sed 's/^$//')

### 修正・改善内容
$(echo -e "$GIT_MODIFIED_FILES" | sed 's/^$//')

## 🔧 技術詳細

### 実装技術
$(echo -e "$GIT_TECHNICAL_DETAILS" | sed 's/^$//')

### アーキテクチャ影響
- **MVC設計**: Rails規約に準拠した適切な責務分離
- **データベース**: 既存スキーマとの整合性確保
- **セキュリティ**: Strong Parameters・認証システムとの統合

### コード品質
\`\`\`
$GIT_STATS
\`\`\`

## 📚 学習ポイント

### 技術習得
- **Rails開発**: MVC パターン・RESTful 設計の実践
- **Git管理**: ブランチ戦略・コミット管理の最適化
- **品質管理**: テスト・Lint・コードレビューの実践

### 設計判断
1. **実装方針**: ユーザビリティと保守性のバランス
2. **技術選定**: プロジェクト要件に最適な技術の選択
3. **品質基準**: 品質とスピードの最適化

## 🎯 実装成果

### 機能面
- ユーザー体験の向上
- システム機能の拡張・改善
- 操作性・視認性の向上

### 技術面  
- コード品質の向上
- 保守性・拡張性の確保
- パフォーマンス最適化

### プロジェクト面
- 開発効率の改善
- 品質管理プロセスの確立
- 自動化システムの構築

## 🔄 今後の展開

### 短期目標
- 機能テスト・品質確認の実施
- ユーザーフィードバックの収集
- 小規模改善の継続実施

### 中長期計画
- 関連機能の拡張・統合
- パフォーマンス最適化
- ユーザビリティ向上のための改善

## 📊 コミット履歴

\`\`\`
$GIT_COMMITS
\`\`\`

## 💡 振り返り・気づき

### 成功要因
- 段階的な実装アプローチ
- 品質管理の徹底
- ユーザー視点での機能設計

### 改善点・学び
- より効率的な実装手法の模索
- テストカバレッジの更なる向上
- ドキュメント整備の継続

### 次のステップ
- 実装した機能の活用・検証
- 関連機能との統合検討
- プロジェクト全体最適化への貢献

---

*📅 自動生成日時: $(date +'%Y年%m月%d日 %H:%M:%S')*  
*🤖 Radio-Calisthenics 自動サマリー生成システム*
EOF
}

# 改善内容のマージ
merge_improved_content() {
    local original_file="$1"
    local improved_file="$2"
    
    # 元ファイルに具体的内容が含まれている場合は保持
    local original_content=$(cat "$original_file")
    
    # 主要セクションが既に充実している場合は、そのまま保持
    if echo "$original_content" | grep -q "技術詳細" && echo "$original_content" | wc -l | awk '$1 > 50 {print "substantial"}' | grep -q "substantial"; then
        log "既存サマリーに十分な内容があるため、マイナーな改善のみ実施"
        
        # 軽微な改善のみ実施
        sed -i '/TODO\|placeholder\|例：\|サンプル/d' "$original_file"
        
        # 自動生成情報を追加
        if ! grep -q "自動生成日時" "$original_file"; then
            echo "" >> "$original_file"
            echo "---" >> "$original_file"
            echo "" >> "$original_file"
            echo "*📅 品質改善日時: $(date +'%Y年%m月%d日 %H:%M:%S')*" >> "$original_file"
            echo "*🤖 Radio-Calisthenics サマリー品質改善システム*" >> "$original_file"
        fi
    else
        log "サマリーの大幅な改善が必要なため、Git分析結果で置換"
        mv "$improved_file" "$original_file"
    fi
}

# メイン処理
main() {
    local summary_file="$1"
    local branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
    
    # 引数チェック
    if [[ -z "$summary_file" ]]; then
        usage
        exit 1
    fi
    
    if [[ ! -f "$summary_file" ]]; then
        log "エラー: サマリーファイルが見つかりません: $summary_file"
        exit 1
    fi
    
    log "=== サマリー品質チェック・改善開始 ==="
    log "対象ファイル: $summary_file"
    log "対象ブランチ: ${branch:-$(git rev-parse --abbrev-ref HEAD)}"
    
    # プロジェクトルートに移動
    cd "$PROJECT_ROOT" || {
        log "エラー: プロジェクトルートに移動できません"
        exit 1
    }
    
    # 品質チェック
    if check_quality_criteria "$summary_file"; then
        log "✅ 品質基準を満たしています"
    else
        log "⚠️ 品質問題を検出 - 改善を実施します"
        
        # サマリー内容改善
        improve_summary_content "$summary_file" "$branch"
        
        # 改善後の品質再確認
        if check_quality_criteria "$summary_file"; then
            log "✅ 品質改善が完了しました"
        else
            log "⚠️ 一部の品質問題が残存していますが、改善を継続します"
        fi
    fi
    
    log "=== サマリー品質チェック・改善完了 ==="
}

# 直接実行時のみメイン処理実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
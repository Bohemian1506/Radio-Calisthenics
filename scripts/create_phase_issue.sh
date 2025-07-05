#!/bin/bash

# =============================================================================
# Phase自動Issue作成スクリプト
# Radio-Calisthenics プロジェクト
# =============================================================================

set -e

PROJECT_ROOT="/home/bohemian1506/workspace/Radio-Calisthenics"
ISSUE_TEMPLATE_PATH="$PROJECT_ROOT/.github/ISSUE_TEMPLATE/phase-implementation.md"

# ログ出力関数
log() {
    echo "[PHASE-ISSUE-CREATOR] $(date +'%Y-%m-%d %H:%M:%S') $1"
}

# 使用方法表示
usage() {
    cat << EOF
Usage: $0 <phase_number> <phase_name> [options]

Phase自動Issue作成スクリプト

Parameters:
  phase_number   Phase番号 (例: 5, 6, 7)
  phase_name     Phase名 (例: "カレンダー画像生成", "ソーシャル機能")

Options:
  --priority <level>    優先度 (high/medium/low, デフォルト: medium)
  --milestone <name>    マイルストーン名 (デフォルト: Phase<N>)
  --assignee <user>     担当者 (デフォルト: Bohemian1506)
  --due-date <date>     期限 (YYYY-MM-DD形式)
  --template <file>     カスタムテンプレートファイル
  --dry-run             実際にIssueを作成せず、内容のみ表示

Examples:
  $0 5 "カレンダー画像生成"
  $0 6 "ソーシャル機能" --priority high --due-date 2025-08-01
  $0 7 "高度データ分析" --milestone "Phase7-Analytics" --dry-run
EOF
}

# Phase実装状況の確認
check_phase_status() {
    local phase_num="$1"
    log "Phase $phase_num の実装状況を確認中..."
    
    # 既存Issueの確認
    local existing_issues=$(gh issue list --label "phase" --state all --search "Phase $phase_num" --json number,title,state --jq '.[] | select(.title | test("Phase '$phase_num'"; "i")) | {number, title, state}')
    
    if [[ -n "$existing_issues" ]]; then
        log "既存のPhase $phase_num 関連Issue:"
        echo "$existing_issues" | jq -r '. | "  #\(.number): \(.title) (\(.state))"'
    fi
    
    # Phase順序の確認
    local prev_phase=$((phase_num - 1))
    if [[ $prev_phase -gt 0 ]]; then
        local prev_phase_issues=$(gh issue list --label "phase" --state all --search "Phase $prev_phase" --json number,title,state --jq '.[] | select(.title | test("Phase '$prev_phase'"; "i")) | select(.state == "open") | {number, title}')
        
        if [[ -n "$prev_phase_issues" ]]; then
            log "⚠️ 警告: Phase $prev_phase が未完了です:"
            echo "$prev_phase_issues" | jq -r '. | "  #\(.number): \(.title)"'
            read -p "Phase $phase_num を作成しますか？ (y/N): " confirm
            if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                log "Issue作成をキャンセルしました"
                exit 0
            fi
        fi
    fi
}

# Phase Issue内容生成
generate_phase_issue_content() {
    local phase_num="$1"
    local phase_name="$2"
    local priority="$3"
    local due_date="$4"
    
    log "Phase $phase_num: $phase_name のIssue内容を生成中..."
    
    # 今日の日付と期限設定
    local today=$(date +'%Y/%m/%d')
    local estimated_due=""
    if [[ -n "$due_date" ]]; then
        estimated_due=$(date -d "$due_date" +'%Y/%m/%d')
    else
        # デフォルト: 2週間後
        estimated_due=$(date -d "+14 days" +'%Y/%m/%d')
    fi
    
    # 優先度設定
    local priority_level="中"
    case "$priority" in
        high) priority_level="高" ;;
        medium) priority_level="中" ;;
        low) priority_level="低" ;;
    esac
    
    # Phase固有の技術要件・タスクを生成
    local tech_requirements=""
    local implementation_tasks=""
    local success_criteria=""
    
    case "$phase_num" in
        5)
            tech_requirements="
### 必要な技術・ライブラリ
- [x] **Rails機能**: ImageMagick統合、ファイル操作、Background Jobs
- [x] **JavaScript/CSS**: Ajax通信、レスポンシブ画像表示、ダウンロード機能
- [x] **データベース**: 画像メタデータ保存、キャッシュ管理
- [x] **外部ライブラリ**: ImageMagick、MiniMagick gem

### アーキテクチャ影響
- [x] **モデル変更**: あり (画像生成履歴・設定管理)
- [x] **コントローラー追加**: あり (CalendarImageController)
- [x] **ビュー実装**: あり (画像生成・プレビュー・ダウンロード画面)
- [x] **ルーティング変更**: あり (画像生成API追加)
- [x] **マイグレーション**: あり (calendar_images テーブル)"

            implementation_tasks="
### Phase 5-1: 基盤構築
- [ ] CalendarImageService設計・実装
- [ ] 画像生成アルゴリズム実装
- [ ] 基本的な画像出力機能
- [ ] エラーハンドリング・ログ実装

### Phase 5-2: 機能実装
- [ ] スタンプ自動配置機能
- [ ] 背景画像統合機能
- [ ] Ajax対応リアルタイム更新
- [ ] レスポンシブ画像表示

### Phase 5-3: 品質・統合
- [ ] パフォーマンス最適化
- [ ] 画像キャッシュシステム
- [ ] 包括的テスト実装
- [ ] ドキュメント・ユーザーガイド作成"

            success_criteria="
### 機能要件
- [ ] 月別カレンダー画像を正確に生成できる
- [ ] スタンプが正しい日付に配置される
- [ ] 複数の背景デザインから選択可能
- [ ] 生成画像をPNG/PDF形式でダウンロード可能

### 技術要件
- [ ] ImageMagick統合の完全動作
- [ ] 大量生成時のメモリ効率性
- [ ] 各種解像度・サイズ対応
- [ ] エラー時の適切な復旧処理"
            ;;
        6)
            tech_requirements="
### 必要な技術・ライブラリ
- [ ] **Rails機能**: Action Cable、通知システム、フォロー機能
- [ ] **JavaScript/CSS**: リアルタイム更新、ソーシャルUI、通知表示
- [ ] **データベース**: フォロー関係、コメント、いいね管理
- [ ] **外部ライブラリ**: Redis、Sidekiq、画像処理

### アーキテクチャ影響
- [ ] **モデル変更**: あり (Follow, Comment, Like モデル追加)
- [ ] **コントローラー追加**: あり (Social系コントローラー群)
- [ ] **ビュー実装**: あり (フィード、プロフィール、通知画面)
- [ ] **ルーティング変更**: あり (ソーシャル機能API追加)
- [ ] **マイグレーション**: あり (ソーシャル関連テーブル群)"

            implementation_tasks="
### Phase 6-1: 基盤構築
- [ ] ユーザーフォローシステム実装
- [ ] 基本ソーシャル機能設計
- [ ] プライバシー設定機能
- [ ] 通知システム基盤構築

### Phase 6-2: 機能実装
- [ ] アクティビティフィード実装
- [ ] コメント・いいね機能
- [ ] ランキング・リーダーボード
- [ ] ソーシャル統計・分析

### Phase 6-3: 品質・統合
- [ ] リアルタイム通知実装
- [ ] プライバシー・セキュリティ強化
- [ ] パフォーマンス最適化
- [ ] ソーシャル機能テスト実装"

            success_criteria="
### 機能要件
- [ ] ユーザー同士でフォロー・フォロワー関係構築
- [ ] 他ユーザーの活動をフィードで閲覧可能
- [ ] コメント・いいねでインタラクション
- [ ] プライバシー設定で公開範囲制御

### 技術要件
- [ ] Action Cableによるリアルタイム通信
- [ ] 大量ユーザー対応のパフォーマンス
- [ ] セキュアなプライバシー制御
- [ ] 通知システムの安定稼働"
            ;;
        *)
            tech_requirements="
### 必要な技術・ライブラリ
- [ ] **Rails機能**: [Phase固有の技術を記載]
- [ ] **JavaScript/CSS**: [フロントエンド要件を記載]
- [ ] **データベース**: [データ設計要件を記載]
- [ ] **外部ライブラリ**: [必要なライブラリを記載]

### アーキテクチャ影響
- [ ] **モデル変更**: [変更の有無と詳細]
- [ ] **コントローラー追加**: [追加・修正の詳細]
- [ ] **ビュー実装**: [新規・修正画面の詳細]
- [ ] **ルーティング変更**: [変更の詳細]
- [ ] **マイグレーション**: [データベース変更の詳細]"

            implementation_tasks="
### Phase $phase_num-1: 基盤構築
- [ ] データベース設計・マイグレーション作成
- [ ] 基本モデル実装・バリデーション
- [ ] 基本コントローラー実装
- [ ] 基本ビュー作成

### Phase $phase_num-2: 機能実装
- [ ] 核となる機能実装
- [ ] UI/UX実装・レスポンシブ対応
- [ ] エラーハンドリング実装
- [ ] セキュリティ対策実装

### Phase $phase_num-3: 品質・統合
- [ ] RSpecテスト実装
- [ ] RuboCop品質チェック通過
- [ ] 統合テスト・動作確認
- [ ] ドキュメント作成・更新"

            success_criteria="
### 機能要件
- [ ] ユーザーが期待通りに機能を利用できる
- [ ] レスポンシブデザインで全デバイス対応
- [ ] エラー時の適切なメッセージ表示
- [ ] セキュリティ要件充足

### 技術要件
- [ ] 全RSpecテスト通過
- [ ] RuboCop 100%準拠
- [ ] Railsベストプラクティス準拠
- [ ] パフォーマンス基準充足"
            ;;
    esac
    
    # Issue内容生成
    cat << EOF
# Phase $phase_num: $phase_name実装

## 📋 概要
**Phase番号**: $phase_num  
**実装予定期間**: $today - $estimated_due  
**優先度**: $priority_level  

### 🎯 実装目標
- [ ] $phase_name の核となる機能実装
- [ ] ユーザー体験の向上
- [ ] システム全体との統合

## 🛠️ 技術要件
$tech_requirements

## 📝 実装タスク
$implementation_tasks

## 📊 成功基準
$success_criteria

### 品質要件
- [ ] コードレビュー完了
- [ ] ドキュメント整備完了
- [ ] 実機テスト完了
- [ ] ユーザビリティ確認完了

## 🔗 関連Phase・Issue

### 前提Phase
- [ ] Phase $((phase_num - 1)): [前のPhase名]

### 次のPhase予定
- [ ] Phase $((phase_num + 1)): [次のPhase計画]

## 📚 参考資料

### 技術ドキュメント
- [ ] [Rails Guides](https://guides.rubyonrails.org/)
- [ ] [Bootstrap ドキュメント](https://getbootstrap.com/docs/)
- [ ] プロジェクト固有ドキュメント: [CLAUDE.md](../CLAUDE.md)

## ⚠️ リスク・注意事項

### 技術的リスク
- [ ] **互換性**: 既存機能への影響確認
- [ ] **パフォーマンス**: 大量データでの動作確認
- [ ] **セキュリティ**: 認証・認可の適切な実装

## 📋 チェックリスト

### 実装開始前
- [ ] 要件理解・技術調査完了
- [ ] 設計書・仕様書確認
- [ ] 開発環境準備完了
- [ ] 関連Phaseの完了確認

### 実装完了時
- [ ] 全機能の動作確認完了
- [ ] テスト・品質チェック完了
- [ ] ドキュメント更新完了
- [ ] レビュー・承認取得

---

## 🤖 AI連携実装

### Claude Code対応
- [ ] 自動実装・リファクタリング対応
- [ ] 品質チェック・改善提案対応
- [ ] Git管理・PR作成自動化対応

### Gemini CLI連携
- [ ] 技術調査・設計検証対応
- [ ] コードレビュー・改善提案対応
- [ ] 大規模実装サポート対応

---

**📅 作成日**: $today  
**👤 作成者**: Bohemian1506  
**🏷️ ラベル**: phase, feature, enhancement
EOF
}

# GitHub Issue作成
create_github_issue() {
    local phase_num="$1"
    local phase_name="$2"
    local priority="$3"
    local milestone="$4"
    local assignee="$5"
    local due_date="$6"
    local dry_run="$7"
    
    # Issue内容生成
    local issue_content=$(generate_phase_issue_content "$phase_num" "$phase_name" "$priority" "$due_date")
    local issue_title="[Phase $phase_num] $phase_name実装"
    
    # ラベル設定
    local labels="phase,feature,enhancement"
    case "$priority" in
        high) labels="$labels,high-priority" ;;
        low) labels="$labels,low-priority" ;;
    esac
    
    if [[ "$dry_run" == "true" ]]; then
        log "=== DRY RUN: Issue作成内容プレビュー ==="
        echo "Title: $issue_title"
        echo "Labels: $labels"
        echo "Assignee: $assignee"
        echo "Milestone: $milestone"
        echo ""
        echo "Content:"
        echo "$issue_content"
        echo ""
        log "=== DRY RUN完了 (実際のIssue作成は行われませんでした) ==="
        return 0
    fi
    
    log "GitHub Issue作成中..."
    
    # GitHub CLI でIssue作成
    local gh_cmd="gh issue create --title \"$issue_title\" --body \"$issue_content\" --label \"$labels\""
    
    if [[ -n "$assignee" ]]; then
        gh_cmd="$gh_cmd --assignee \"$assignee\""
    fi
    
    if [[ -n "$milestone" ]]; then
        # マイルストーンが存在するかチェック
        local milestone_exists=$(gh api repos/:owner/:repo/milestones --jq ".[] | select(.title == \"$milestone\") | .number" 2>/dev/null || echo "")
        
        if [[ -n "$milestone_exists" ]]; then
            gh_cmd="$gh_cmd --milestone \"$milestone\""
        else
            log "⚠️ マイルストーン '$milestone' が存在しません。マイルストーンなしで作成します。"
        fi
    fi
    
    # Issue作成実行
    local issue_url=$(eval "$gh_cmd")
    
    if [[ $? -eq 0 ]]; then
        log "✅ Issue作成完了: $issue_url"
        
        # 作成後の追加設定
        local issue_number=$(echo "$issue_url" | sed 's/.*\/\([0-9]*\)$/\1/')
        
        if [[ -n "$due_date" ]]; then
            log "期限設定: $due_date (GitHub Issue内のコメントで記録)"
            echo "📅 **実装期限**: $due_date" | gh issue comment "$issue_number" --body-file -
        fi
        
        echo "$issue_url"
    else
        log "❌ Issue作成に失敗しました"
        return 1
    fi
}

# マイルストーン自動作成
ensure_milestone() {
    local milestone="$1"
    local due_date="$2"
    
    if [[ -z "$milestone" ]]; then
        return 0
    fi
    
    # マイルストーンの存在確認
    local milestone_exists=$(gh api repos/:owner/:repo/milestones --jq ".[] | select(.title == \"$milestone\") | .number" 2>/dev/null || echo "")
    
    if [[ -z "$milestone_exists" ]]; then
        log "マイルストーン '$milestone' が存在しないため作成します..."
        
        local milestone_description="Radio-Calisthenics $milestone の実装管理"
        local create_cmd="gh api repos/:owner/:repo/milestones -f title=\"$milestone\" -f description=\"$milestone_description\""
        
        if [[ -n "$due_date" ]]; then
            # ISO 8601形式に変換
            local iso_date=$(date -d "$due_date" --iso-8601=seconds)
            create_cmd="$create_cmd -f due_on=\"$iso_date\""
        fi
        
        if eval "$create_cmd" >/dev/null 2>&1; then
            log "✅ マイルストーン作成完了: $milestone"
        else
            log "⚠️ マイルストーン作成に失敗しました: $milestone"
        fi
    fi
}

# メイン処理
main() {
    local phase_num="$1"
    local phase_name="$2"
    
    # 引数チェック
    if [[ -z "$phase_num" ]] || [[ -z "$phase_name" ]]; then
        usage
        exit 1
    fi
    
    # オプション解析
    local priority="medium"
    local milestone="Phase$phase_num"
    local assignee="Bohemian1506"
    local due_date=""
    local template=""
    local dry_run="false"
    
    shift 2
    while [[ $# -gt 0 ]]; do
        case $1 in
            --priority)
                priority="$2"
                shift 2
                ;;
            --milestone)
                milestone="$2"
                shift 2
                ;;
            --assignee)
                assignee="$2"
                shift 2
                ;;
            --due-date)
                due_date="$2"
                shift 2
                ;;
            --template)
                template="$2"
                shift 2
                ;;
            --dry-run)
                dry_run="true"
                shift
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
    
    log "=== Phase Issue自動作成開始 ==="
    log "Phase: $phase_num - $phase_name"
    log "優先度: $priority"
    log "担当者: $assignee"
    log "マイルストーン: $milestone"
    
    # プロジェクトルートに移動
    cd "$PROJECT_ROOT" || {
        log "エラー: プロジェクトルートに移動できません"
        exit 1
    }
    
    # Git作業ディレクトリ確認
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log "エラー: Gitリポジトリではありません"
        exit 1
    fi
    
    # GitHub CLI認証確認
    if ! gh auth status >/dev/null 2>&1; then
        log "エラー: GitHub CLI認証が必要です。'gh auth login' を実行してください"
        exit 1
    fi
    
    # Phase実装状況確認
    if [[ "$dry_run" != "true" ]]; then
        check_phase_status "$phase_num"
    fi
    
    # マイルストーン確保
    if [[ "$dry_run" != "true" ]]; then
        ensure_milestone "$milestone" "$due_date"
    fi
    
    # Issue作成
    local issue_url=$(create_github_issue "$phase_num" "$phase_name" "$priority" "$milestone" "$assignee" "$due_date" "$dry_run")
    
    if [[ "$dry_run" != "true" && -n "$issue_url" ]]; then
        log "=== Phase Issue作成完了 ==="
        log "Issue URL: $issue_url"
        log "次のステップ: Issue内容を確認し、必要に応じて詳細を追記してください"
    fi
}

# 直接実行時のみメイン処理実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
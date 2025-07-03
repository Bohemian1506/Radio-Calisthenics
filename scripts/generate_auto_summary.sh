#!/bin/bash

# =============================================================================
# 作業完了後自動サマリー生成システム
# Radio-Calisthenics プロジェクト
# =============================================================================

set -e

PROJECT_ROOT="/home/bohemian1506/workspace/Radio-Calisthenics"
SUMMARIES_DIR="$PROJECT_ROOT/summaries"
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
DATE_ONLY=$(date +"%Y-%m-%d")

# ログ出力関数
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Git情報分析関数
analyze_git_changes() {
    log "Git変更情報を分析中..."
    
    # 最新コミット情報
    LATEST_COMMIT=$(git log --oneline -1)
    COMMIT_MESSAGE=$(git log --format="%s" -1)
    COMMIT_AUTHOR=$(git log --format="%an" -1)
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    # 変更ファイル分析
    CHANGED_FILES=$(git diff --name-status HEAD~1 HEAD 2>/dev/null || echo "")
    FILE_STATS=$(git diff --stat HEAD~1 HEAD 2>/dev/null || echo "")
    
    # コミット分類判定
    if [[ "$COMMIT_MESSAGE" == *"feat:"* ]]; then
        WORK_TYPE="feature"
        WORK_CATEGORY="機能実装"
    elif [[ "$COMMIT_MESSAGE" == *"fix:"* ]]; then
        WORK_TYPE="bugfix"
        WORK_CATEGORY="バグ修正"
    elif [[ "$COMMIT_MESSAGE" == *"refactor:"* ]]; then
        WORK_TYPE="refactor"
        WORK_CATEGORY="リファクタリング"
    elif [[ "$COMMIT_MESSAGE" == *"style:"* ]]; then
        WORK_TYPE="style"
        WORK_CATEGORY="スタイル修正"
    elif [[ "$COMMIT_MESSAGE" == *"docs:"* ]]; then
        WORK_TYPE="docs"
        WORK_CATEGORY="ドキュメント更新"
    elif [[ "$COMMIT_MESSAGE" == *"test:"* ]]; then
        WORK_TYPE="test"
        WORK_CATEGORY="テスト実装"
    else
        WORK_TYPE="general"
        WORK_CATEGORY="一般的な作業"
    fi
    
    log "作業分類: $WORK_CATEGORY ($WORK_TYPE)"
}

# 作業内容分析関数
analyze_work_content() {
    log "作業内容を詳細分析中..."
    
    # Phase判定
    if [[ "$COMMIT_MESSAGE" == *"Phase"* ]]; then
        PHASE_INFO=$(echo "$COMMIT_MESSAGE" | grep -o "Phase[0-9]\+")
        TARGET_DIR="$SUMMARIES_DIR/phases"
    # 自動化・システム関連
    elif [[ "$COMMIT_MESSAGE" == *"自動"* || "$COMMIT_MESSAGE" == *"auto"* || "$COMMIT_MESSAGE" == *"system"* ]]; then
        TARGET_DIR="$SUMMARIES_DIR/development"
    # 技術実装関連
    elif [[ "$WORK_TYPE" == "feature" || "$WORK_TYPE" == "refactor" ]]; then
        TARGET_DIR="$SUMMARIES_DIR/technical"
    # プロジェクト管理関連
    elif [[ "$WORK_TYPE" == "docs" || "$COMMIT_MESSAGE" == *"planning"* || "$COMMIT_MESSAGE" == *"設計"* ]]; then
        TARGET_DIR="$SUMMARIES_DIR/project"
    else
        TARGET_DIR="$SUMMARIES_DIR/development"
    fi
    
    log "保存先ディレクトリ: $TARGET_DIR"
}

# ファイル変更詳細分析
analyze_file_changes() {
    NEW_FILES=""
    MODIFIED_FILES=""
    DELETED_FILES=""
    
    if [[ -n "$CHANGED_FILES" ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ ^A[[:space:]]+(.+) ]]; then
                NEW_FILES="$NEW_FILES\n- ${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^M[[:space:]]+(.+) ]]; then
                MODIFIED_FILES="$MODIFIED_FILES\n- ${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^D[[:space:]]+(.+) ]]; then
                DELETED_FILES="$DELETED_FILES\n- ${BASH_REMATCH[1]}"
            fi
        done <<< "$CHANGED_FILES"
    fi
}

# 技術的詳細分析
analyze_technical_details() {
    TECHNICAL_HIGHLIGHTS=""
    
    # Rails関連の検出
    if echo "$CHANGED_FILES" | grep -q "controllers\|models\|views"; then
        TECHNICAL_HIGHLIGHTS="$TECHNICAL_HIGHLIGHTS\n- Rails MVC構造の実装・修正"
    fi
    
    # データベース関連の検出
    if echo "$CHANGED_FILES" | grep -q "migrate\|schema"; then
        TECHNICAL_HIGHLIGHTS="$TECHNICAL_HIGHLIGHTS\n- データベース設計・マイグレーション"
    fi
    
    # フロントエンド関連の検出
    if echo "$CHANGED_FILES" | grep -q "\.scss\|\.css\|\.js"; then
        TECHNICAL_HIGHLIGHTS="$TECHNICAL_HIGHLIGHTS\n- フロントエンド・UI/UX実装"
    fi
    
    # テスト関連の検出
    if echo "$CHANGED_FILES" | grep -q "spec\|test"; then
        TECHNICAL_HIGHLIGHTS="$TECHNICAL_HIGHLIGHTS\n- テストコード実装・品質向上"
    fi
    
    # 設定・自動化の検出
    if echo "$CHANGED_FILES" | grep -q "scripts\|hooks\|config"; then
        TECHNICAL_HIGHLIGHTS="$TECHNICAL_HIGHLIGHTS\n- 開発環境・自動化システム構築"
    fi
}

# 学習ポイント抽出
extract_learning_points() {
    LEARNING_POINTS=""
    
    case "$WORK_TYPE" in
        "feature")
            LEARNING_POINTS="- 新機能実装における設計・開発プロセス
- ユーザー要求から技術実装への変換手法
- MVC アーキテクチャでの責務分離
- UI/UX設計とユーザビリティ向上"
            ;;
        "bugfix")
            LEARNING_POINTS="- 問題の根本原因分析・解決手法
- デバッグプロセス・エラーハンドリング
- 修正による副作用の考慮・検証方法
- 再発防止のためのテスト強化"
            ;;
        "refactor")
            LEARNING_POINTS="- コード品質向上・保守性改善
- パフォーマンス最適化手法
- 設計パターンの適用・リファクタリング
- 技術的負債の解消プロセス"
            ;;
        "style")
            LEARNING_POINTS="- コーディング規約・スタイルガイド遵守
- 自動Lintツール活用・品質管理
- チーム開発での一貫性確保
- 可読性・保守性の向上"
            ;;
        *)
            LEARNING_POINTS="- 継続的な学習・スキル向上
- プロジェクト管理・開発プロセス改善
- 品質管理・コードレビューの重要性
- チームワーク・コミュニケーションスキル"
            ;;
    esac
}

# 初学者向け解説生成
generate_beginner_explanation() {
    BEGINNER_SECTION=""
    
    case "$WORK_TYPE" in
        "feature")
            BEGINNER_SECTION="## 🔰 初学者向け解説

### 今回実装した機能について
$WORK_CATEGORY として、以下の新機能を実装しました：

#### 何を作ったのか？
- **機能概要**: $(echo "$COMMIT_MESSAGE" | sed 's/feat: //')
- **ユーザーメリット**: この機能により、ユーザーは[具体的なメリット]を得られます
- **技術的意義**: Rails MVCパターンに従った適切な実装を学習

#### どのように作ったのか？
1. **要求分析**: ユーザーニーズの理解・技術要件への変換
2. **設計**: MVC各層での責務分離・データベース設計
3. **実装**: Rails規約に従った段階的実装
4. **テスト**: 品質確保・動作確認・セキュリティチェック

#### なぜこの方法を選んだのか？
- **Rails規約重視**: Convention over Configuration の原則
- **保守性優先**: 将来の機能拡張・メンテナンスを考慮
- **学習効果**: 初学者が理解しやすい明確な構造
- **セキュリティ**: Secure by Default の実装"
            ;;
        "bugfix")
            BEGINNER_SECTION="## 🔰 初学者向け解説

### バグ修正から学ぶこと
$WORK_CATEGORY を通じて、以下を学習しました：

#### 問題の発見と分析
- **症状**: [具体的な問題の症状]
- **影響範囲**: ユーザーへの影響・システムへの影響
- **根本原因**: 技術的な原因・設計上の問題

#### 解決アプローチ
1. **問題再現**: 確実な問題の特定・再現環境構築
2. **原因調査**: ログ分析・デバッグ・コードレビュー
3. **解決方針**: 最小限の変更で最大の効果
4. **テスト**: 修正内容の検証・副作用チェック

#### 予防策・学習ポイント
- **テスト強化**: 同様の問題を防ぐテストケース追加
- **コードレビュー**: チーム内での知識共有・品質向上
- **エラーハンドリング**: 適切な例外処理・ユーザーフィードバック"
            ;;
        *)
            BEGINNER_SECTION="## 🔰 初学者向け解説

### 今回の作業について
$WORK_CATEGORY として実施した内容を解説します。

#### 作業の目的と背景
- **何のために**: [作業の目的・背景]
- **どのような効果**: プロジェクト・チーム・個人への影響
- **学習価値**: この作業から得られる技術的知見

#### 実装・作業プロセス
1. **計画立案**: 要件整理・技術検討・リスク評価
2. **実装・実行**: 段階的実施・品質確保
3. **検証・確認**: 動作確認・品質チェック・影響範囲確認
4. **振り返り**: 学習ポイント整理・今後の改善点

#### 技術的学習ポイント
- **使用技術**: 今回活用した技術・ツール・フレームワーク
- **設計思想**: なぜこの実装方法を選択したか
- **ベストプラクティス**: 業界標準・推奨手法の適用"
            ;;
    esac
}

# サマリーファイル生成
generate_summary_file() {
    log "サマリーファイルを生成中..."
    
    # ファイル名生成
    SUMMARY_TITLE=$(echo "$COMMIT_MESSAGE" | sed 's/^[a-z]*: //' | sed 's/[^a-zA-Z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]/_/g')
    FILENAME="${DATE_ONLY}_${WORK_TYPE}_${SUMMARY_TITLE}.md"
    FILEPATH="$TARGET_DIR/$FILENAME"
    
    # ディレクトリ作成
    mkdir -p "$TARGET_DIR"
    
    # ファイル変更詳細分析
    analyze_file_changes
    analyze_technical_details
    extract_learning_points
    generate_beginner_explanation
    
    # サマリーファイル生成
    cat > "$FILEPATH" << EOF
# $(echo "$COMMIT_MESSAGE" | sed 's/^[a-z]*: //')

**作業完了日**: $(date +'%Y年%m月%d日 %H:%M')  
**作業分類**: $WORK_CATEGORY  
**作業ブランチ**: \`$CURRENT_BRANCH\`  
**コミット**: \`$LATEST_COMMIT\`  
**作業者**: $COMMIT_AUTHOR  

## 📋 作業概要

### 実施内容
$(echo "$COMMIT_MESSAGE" | sed 's/^[a-z]*: //')

### 作業背景・目的
ブランチ \`$CURRENT_BRANCH\` での作業として実施。

## 📂 変更ファイル詳細

### 新規ファイル$(if [[ -n "$NEW_FILES" ]]; then echo -e "$NEW_FILES"; else echo -e "\n- なし"; fi)

### 修正ファイル$(if [[ -n "$MODIFIED_FILES" ]]; then echo -e "$MODIFIED_FILES"; else echo -e "\n- なし"; fi)

### 削除ファイル$(if [[ -n "$DELETED_FILES" ]]; then echo -e "$DELETED_FILES"; else echo -e "\n- なし"; fi)

### 変更統計
\`\`\`
$FILE_STATS
\`\`\`

## 🔧 技術的実装詳細

### 主要な技術的変更$(if [[ -n "$TECHNICAL_HIGHLIGHTS" ]]; then echo -e "$TECHNICAL_HIGHLIGHTS"; else echo -e "\n- 詳細な技術変更なし"; fi)

### 実装アプローチ
- **技術選択理由**: [なぜこの技術・手法を選択したか]
- **設計判断**: [重要な設計決定とその根拠]
- **品質保証**: [テスト・コードレビュー・検証方法]

### アーキテクチャへの影響
- **システム構造**: [既存システムへの影響・拡張性]
- **パフォーマンス**: [処理速度・メモリ使用量等への影響]
- **保守性**: [今後のメンテナンス・拡張の容易さ]

$BEGINNER_SECTION

## 📚 学習成果・ポイント

### 技術的学習内容
$LEARNING_POINTS

### プロセス・手法の学習
- **開発プロセス**: 計画→実装→テスト→デプロイの流れ
- **品質管理**: コードレビュー・テスト・Lint等の活用
- **チームワーク**: コミュニケーション・知識共有・相互支援
- **問題解決**: 課題発見・分析・解決・検証のサイクル

### 今後の応用・発展
- **類似作業**: 今回の学習を活かせる場面
- **スキル向上**: さらに伸ばすべき技術・知識
- **キャリア**: 専門性向上・市場価値向上への貢献

## 🎯 次のステップ・課題

### 短期的な課題（1-2週間）
- [ ] 今回実装した機能の運用・監視
- [ ] ユーザーフィードバックの収集・分析
- [ ] 小さな改善・最適化の継続実施

### 中期的な目標（1-3ヶ月）
- [ ] 関連機能の拡張・統合
- [ ] パフォーマンス最適化・セキュリティ強化
- [ ] 技術スタックの理解深化・応用

### 長期的な成長（6ヶ月-1年）
- [ ] より高度な技術・アーキテクチャの習得
- [ ] プロジェクトリーダーシップの発揮
- [ ] 技術コミュニティへの貢献・知識共有

## 💡 重要な気づき・教訓

### 技術的な気づき
- [今回の作業で得た重要な技術的洞察]
- [期待と異なった結果・学び]
- [今後注意すべき技術的ポイント]

### プロセス・手法の気づき
- [効果的だった開発手法・ツール]
- [改善すべきプロセス・習慣]
- [チームワーク・コミュニケーションの学び]

### 個人的成長
- [新しく身についたスキル・知識]
- [克服した課題・困難]
- [自信がついた分野・今後伸ばしたい分野]

## 📊 定量的成果（該当する場合）

### コード品質指標
- **行数**: 追加 [X] 行、削除 [Y] 行
- **テストカバレッジ**: [XX]%
- **Lint準拠**: 違反 [Z] 件

### パフォーマンス指標
- **処理速度**: [具体的な改善数値]
- **メモリ使用量**: [変化量]
- **ユーザー体験**: [応答時間・操作性の改善]

### ビジネス価値
- **ユーザーメリット**: [具体的な価値提供]
- **開発効率**: [作業時間短縮・品質向上]
- **運用改善**: [保守性・監視性の向上]

---

## 📝 参考資料・関連リンク

### 技術ドキュメント
- [関連する公式ドキュメント・チュートリアル]
- [参考にした技術記事・ブログ]
- [使用したライブラリ・ツールのドキュメント]

### プロジェクト内関連ファイル
- [関連するCLAUDE.md セクション]
- [関連する他のサマリーファイル]
- [重要な設計ドキュメント・仕様書]

---

*🤖 この学習記録は自動生成システムにより作成されました*  
*📅 生成日時: $(date +'%Y年%m月%d日 %H:%M:%S')*  
*🔧 生成システム: Radio-Calisthenics Auto Summary Generator v1.0*
EOF

    log "サマリーファイルを生成完了: $FILEPATH"
    
    # ファイルパスのみを返す
    echo "$FILEPATH"
}

# メイン処理
main() {
    log "=== Radio-Calisthenics 自動サマリー生成システム開始 ==="
    
    # Git作業ディレクトリ確認
    cd "$PROJECT_ROOT"
    
    # Git変更情報分析
    analyze_git_changes
    
    # 作業内容分析
    analyze_work_content
    
    # サマリーファイル生成
    GENERATED_FILE=$(generate_summary_file)
    
    log "=== 自動サマリー生成完了 ==="
    log "生成ファイル: $GENERATED_FILE"
    
    # 品質改善システム実行
    local quality_script="$PROJECT_ROOT/scripts/analyze_summary_quality.sh"
    if [[ -f "$quality_script" ]]; then
        log "サマリー品質改善システム実行中..."
        if "$quality_script" "$GENERATED_FILE" "$CURRENT_BRANCH"; then
            log "✅ サマリー品質改善完了"
        else
            log "⚠️ 品質改善で問題が発生しましたが、基本サマリーは生成済みです"
        fi
    else
        log "注意: 品質改善スクリプトが見つかりません"
    fi
    
    # summariesディレクトリはgitignoreされているため、コミットには含まれない
    log "注意: サマリーファイルは .gitignore により追跡対象外です"
    
    return 0
}

# 直接実行時のみメイン処理実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
# カレンダー画像生成実装計画

## Git管理・作業手順
### 事前準備
1. **mainブランチの最新化確認**
   ```bash
   git checkout main
   git pull origin main
   git status  # クリーンな状態を確認
   ```

2. **作業ブランチ作成**
   ```bash
   git checkout -b feature/calendar-image-generation
   ```

## 現状分析
- 既存: HTMLベースのカレンダー表示（CSS + Bootstrap）
- 既存: StampCardImageService（基本的な画像生成機能）
- 要求: [Image #1]を使用してImageMagick + MiniMagickでカレンダー画像を生成

## 実装計画

### 1. CalendarImageService作成（新規サービス）
```ruby
# app/services/calendar_image_service.rb
class CalendarImageService
  # 月間カレンダー画像を生成
  - 背景画像（[Image #1]）を使用
  - カレンダーグリッドの描画
  - スタンプマークの配置
  - 日付・曜日の文字描画
  - レスポンシブ対応
end
```

### 2. コントローラー機能追加
```ruby
# StampCardsController
def generate_calendar_image
  # 月間カレンダー画像生成
  # Ajax対応（リアルタイム生成）
  # 一時ファイル管理
end

def view_calendar_image
  # 生成済みカレンダー画像の表示
  # キャッシュ機能
end
```

### 3. ルーティング追加
```ruby
resources :stamp_cards do
  collection do
    post :generate_calendar_image
    get :view_calendar_image
  end
end
```

### 4. Viewの変更
```erb
<!-- HTMLカレンダーから画像カレンダーへ変更 -->
<div class="calendar-image-container">
  <img id="calendar-image" src="/stamp_cards/view_calendar_image" />
  <button onclick="generateCalendarImage()">カレンダー更新</button>
</div>
```

### 5. 画像生成詳細仕様
- **背景**: [Image #1]をベース画像として使用
- **レイアウト**: 7x6グリッド（週x週数）
- **スタンプ表示**: 参加日にスタンプ画像を合成
- **インタラクティブ**: Ajax経由でリアルタイム更新
- **キャッシュ**: 同月・同ユーザーの画像キャッシュ

### 6. 技術要素
- **ImageMagick/MiniMagick**: 画像合成・文字描画
- **一時ファイル管理**: セッション連携
- **Ajax通信**: カレンダー更新時の非同期処理
- **エラーハンドリング**: 画像生成失敗時の対応

### 7. 実装順序
1. **Git作業準備** (mainブランチ最新化→作業ブランチ作成)
2. CalendarImageService作成・基本機能実装
3. コントローラーアクション追加
4. ルーティング設定
5. View修正（HTML→画像表示）
6. Ajax機能実装
7. テスト・動作確認
8. **PR作成** (feature/calendar-image-generation → main)

## 重要な注意事項
- **必ずmainブランチの最新状態から開始**
- **作業は専用ブランチで実施（feature/calendar-image-generation）**
- **この新しい計画が古い実装計画より優先**

## 実装詳細

### CalendarImageService 設計仕様

#### 基本構造
```ruby
class CalendarImageService
  attr_reader :user, :year, :month, :calendar_data

  def initialize(user:, year:, month:)
    @user = user
    @year = year
    @month = month
    @calendar_data = load_calendar_data
  end

  def generate
    # 1. 背景画像読み込み
    # 2. カレンダーグリッド描画
    # 3. 日付・曜日テキスト描画
    # 4. スタンプマーク配置
    # 5. 最終画像生成
  end

  private

  def load_background_image
    # [Image #1]を読み込み
  end

  def draw_calendar_grid
    # 7x6のカレンダーグリッドを描画
  end

  def draw_dates_and_weekdays
    # 日付と曜日を適切な位置に描画
  end

  def place_stamp_marks
    # 参加日にスタンプ画像を配置
  end
end
```

#### 画像生成パラメータ
- **画像サイズ**: 800x600px（レスポンシブ対応）
- **グリッドサイズ**: 7列×6行
- **セルサイズ**: 100x80px
- **フォント**: 日本語対応フォント
- **色設定**: 
  - 平日: 黒文字
  - 土曜: 青文字
  - 日曜: 赤文字
  - 今日: ハイライト背景

#### エラーハンドリング
- 背景画像が見つからない場合
- ImageMagick処理失敗時
- フォント読み込み失敗時
- メモリ不足時

### Ajax実装仕様

#### フロントエンド
```javascript
function generateCalendarImage(year, month) {
  fetch('/stamp_cards/generate_calendar_image', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
    },
    body: JSON.stringify({ year: year, month: month })
  })
  .then(response => response.json())
  .then(data => {
    if (data.status === 'success') {
      document.getElementById('calendar-image').src = data.image_url;
    }
  });
}
```

#### バックエンド
```ruby
def generate_calendar_image
  service = CalendarImageService.new(
    user: current_user,
    year: params[:year].to_i,
    month: params[:month].to_i
  )
  
  image = service.generate
  temp_file = Tempfile.new(['calendar', '.png'])
  service.save_to_file(temp_file.path)
  
  session[:calendar_image_path] = temp_file.path
  
  render json: {
    status: 'success',
    image_url: view_calendar_image_stamp_cards_path(year: params[:year], month: params[:month])
  }
end
```

この計画で、現在のHTMLカレンダーをImageMagick生成の画像カレンダーに置き換えます。
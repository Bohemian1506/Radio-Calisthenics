import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "container"]
  static values = { 
    calendarData: Array,
    currentMonth: String,
    currentYear: Number,
    theme: String
  }

  connect() {
    console.log("StampCardCanvas controller connected")
    
    // パフォーマンス最適化の初期化
    this.animationScheduled = false
    this.pendingUpdates = []
    this.lastDrawTime = 0
    this.drawThrottleMs = 16 // 60fps相当
    
    this.setupCanvas()
    this.setupEventListeners()
    this.scheduleRedraw()
  }

  disconnect() {
    this.removeEventListeners()
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
    }
    
    // アニメーションフレームのキャンセル
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId)
    }
  }

  setupCanvas() {
    const canvas = this.canvasTarget
    const container = this.containerTarget
    const ctx = canvas.getContext('2d')
    
    // デバイスピクセル比対応
    const dpr = window.devicePixelRatio || 1
    this.devicePixelRatio = dpr
    
    // Canvas寸法の初期計算
    this.updateCanvasSize()
    
    // Canvas初期化
    this.initializeCanvas()
    
    console.log(`Canvas initialized: ${canvas.width}x${canvas.height}, DPR: ${dpr}`)
  }

  updateCanvasSize() {
    const canvas = this.canvasTarget
    const container = this.containerTarget
    
    // コンテナの幅を基準に計算
    const containerWidth = container.offsetWidth
    const padding = 20 // 左右の余白
    const canvasWidth = containerWidth - padding
    
    // 7:6の比率でカレンダーサイズを計算
    const canvasHeight = Math.floor(canvasWidth * 6 / 7)
    
    // Canvas要素のサイズ設定
    canvas.style.width = canvasWidth + 'px'
    canvas.style.height = canvasHeight + 'px'
    
    // 高DPI対応のための実際のCanvas寸法
    canvas.width = canvasWidth * this.devicePixelRatio
    canvas.height = canvasHeight * this.devicePixelRatio
    
    // 座標系の設定
    this.canvasWidth = canvasWidth
    this.canvasHeight = canvasHeight
    this.cellWidth = canvasWidth / 7
    this.cellHeight = canvasHeight / 6
    
    console.log(`Canvas resized: ${canvasWidth}x${canvasHeight}, Cell: ${this.cellWidth}x${this.cellHeight}`)
  }

  initializeCanvas() {
    const canvas = this.canvasTarget
    const ctx = canvas.getContext('2d')
    
    // 高DPI対応のスケーリング
    ctx.scale(this.devicePixelRatio, this.devicePixelRatio)
    
    // アンチエイリアス設定
    ctx.imageSmoothingEnabled = true
    ctx.imageSmoothingQuality = 'high'
    
    // 初期クリア
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
  }

  setupEventListeners() {
    // リサイズイベントのハンドリング
    this.resizeHandler = this.handleResize.bind(this)
    window.addEventListener('resize', this.resizeHandler)
    
    // Canvas上のマウスイベント
    this.mouseHandler = this.handleMouseEvent.bind(this)
    this.canvasTarget.addEventListener('mousemove', this.mouseHandler)
    this.canvasTarget.addEventListener('mouseout', this.mouseHandler)
    this.canvasTarget.addEventListener('click', this.mouseHandler)
    
    // ResizeObserverでコンテナのサイズ変更を監視
    if (window.ResizeObserver) {
      this.resizeObserver = new ResizeObserver(entries => {
        for (let entry of entries) {
          this.handleResize()
        }
      })
      this.resizeObserver.observe(this.containerTarget)
    }
  }

  removeEventListeners() {
    if (this.resizeHandler) {
      window.removeEventListener('resize', this.resizeHandler)
    }
    if (this.mouseHandler) {
      this.canvasTarget.removeEventListener('mousemove', this.mouseHandler)
      this.canvasTarget.removeEventListener('mouseout', this.mouseHandler)
      this.canvasTarget.removeEventListener('click', this.mouseHandler)
    }
  }

  handleResize() {
    // リサイズイベントを間引く
    if (this.resizeTimeout) {
      clearTimeout(this.resizeTimeout)
    }
    
    this.resizeTimeout = setTimeout(() => {
      this.updateCanvasSize()
      this.initializeCanvas()
      this.scheduleRedraw()
    }, 100)
  }

  handleMouseEvent(event) {
    const rect = this.canvasTarget.getBoundingClientRect()
    const x = event.clientX - rect.left
    const y = event.clientY - rect.top
    
    // セルの位置を計算
    const col = Math.floor(x / this.cellWidth)
    const row = Math.floor(y / this.cellHeight)
    
    // 範囲チェック
    if (col >= 0 && col < 7 && row >= 0 && row < 6) {
      const cellIndex = row * 7 + col
      
      if (event.type === 'mousemove') {
        this.handleCellHover(cellIndex, x, y)
      } else if (event.type === 'mouseout') {
        this.handleMouseLeave()
      } else if (event.type === 'click') {
        this.handleCellClick(cellIndex)
      }
    } else if (event.type === 'mouseout') {
      this.handleMouseLeave()
    }
  }

  handleCellHover(cellIndex, x, y) {
    if (this.hoveredCell !== cellIndex) {
      this.hoveredCell = cellIndex
      this.scheduleRedraw()
    }
  }

  handleMouseLeave() {
    if (this.hoveredCell !== null) {
      this.hoveredCell = null
      this.scheduleRedraw()
    }
  }

  handleCellClick(cellIndex) {
    const calendarData = this.calendarDataValue
    if (calendarData && calendarData.length > 0) {
      const weekIndex = Math.floor(cellIndex / 7)
      const dayIndex = cellIndex % 7
      
      if (weekIndex < calendarData.length && dayIndex < calendarData[weekIndex].length) {
        const dayData = calendarData[weekIndex][dayIndex]
        
        if (dayData && dayData.can_stamp) {
          this.stampDate(dayData.date)
        }
      }
    }
  }

  stampDate(date) {
    console.log(`Stamping date: ${date}`)
    
    // スタンプ用のフォームを作成して送信
    const form = document.createElement('form')
    form.method = 'POST'
    form.action = '/stamp_cards'
    form.style.display = 'none'
    
    // CSRFトークン
    const csrfToken = document.querySelector('meta[name="csrf-token"]')
    if (csrfToken) {
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = csrfToken.content
      form.appendChild(csrfInput)
    }
    
    // 日付
    const dateInput = document.createElement('input')
    dateInput.type = 'hidden'
    dateInput.name = 'stamp_card[date]'
    dateInput.value = date
    form.appendChild(dateInput)
    
    document.body.appendChild(form)
    form.submit()
    document.body.removeChild(form)
  }

  // パフォーマンス最適化: requestAnimationFrameを使った描画スケジューリング
  scheduleRedraw() {
    if (!this.animationScheduled) {
      this.animationScheduled = true
      this.animationFrameId = requestAnimationFrame((timestamp) => {
        this.performDraw(timestamp)
        this.animationScheduled = false
      })
    }
  }

  performDraw(timestamp) {
    // フレームレート制限（60fps）
    if (timestamp - this.lastDrawTime < this.drawThrottleMs) {
      this.scheduleRedraw()
      return
    }

    this.lastDrawTime = timestamp
    this.drawCalendar()
    
    // 保留中の更新があれば処理
    this.processPendingUpdates()
  }

  processPendingUpdates() {
    if (this.pendingUpdates.length > 0) {
      console.log(`Processing ${this.pendingUpdates.length} pending updates`)
      this.pendingUpdates.forEach(update => {
        if (update.type === 'stamp') {
          this.updateStampVisual(update.cellIndex, update.data)
        }
      })
      this.pendingUpdates = []
    }
  }

  updateStampVisual(cellIndex, data) {
    // 差分描画: 特定のセルのみ更新
    const col = cellIndex % 7
    const row = Math.floor(cellIndex / 7)
    const x = col * this.cellWidth
    const y = row * this.cellHeight
    
    const ctx = this.canvasTarget.getContext('2d')
    
    // 該当セル領域をクリア
    ctx.clearRect(x, y, this.cellWidth, this.cellHeight)
    
    // セルを再描画
    this.drawDayCell(ctx, data, col, row, cellIndex)
  }

  drawCalendar() {
    const canvas = this.canvasTarget
    const ctx = canvas.getContext('2d')
    
    // Canvas全体をクリア
    ctx.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
    
    // 背景色
    ctx.fillStyle = '#ffffff'
    ctx.fillRect(0, 0, this.canvasWidth, this.canvasHeight)
    
    // カレンダーデータの描画
    this.drawCalendarGrid()
    this.drawCalendarData()
  }

  drawCalendarGrid() {
    const ctx = this.canvasTarget.getContext('2d')
    
    // グリッドライン
    ctx.strokeStyle = '#dee2e6'
    ctx.lineWidth = 1
    
    ctx.beginPath()
    
    // 縦線
    for (let i = 0; i <= 7; i++) {
      const x = i * this.cellWidth
      ctx.moveTo(x, 0)
      ctx.lineTo(x, this.canvasHeight)
    }
    
    // 横線
    for (let i = 0; i <= 6; i++) {
      const y = i * this.cellHeight
      ctx.moveTo(0, y)
      ctx.lineTo(this.canvasWidth, y)
    }
    
    ctx.stroke()
  }

  drawCalendarData() {
    const calendarData = this.calendarDataValue
    if (!calendarData || calendarData.length === 0) {
      console.log("No calendar data available")
      return
    }
    
    const ctx = this.canvasTarget.getContext('2d')
    
    calendarData.forEach((week, weekIndex) => {
      week.forEach((dayData, dayIndex) => {
        const cellIndex = weekIndex * 7 + dayIndex
        this.drawDayCell(ctx, dayData, dayIndex, weekIndex, cellIndex)
      })
    })
  }

  drawDayCell(ctx, dayData, col, row, cellIndex) {
    const x = col * this.cellWidth
    const y = row * this.cellHeight
    
    // セルの背景色
    let bgColor = '#ffffff'
    if (!dayData.current_month) {
      bgColor = '#f8f9fa'
    } else if (dayData.today) {
      bgColor = '#e3f2fd'
    } else if (dayData.stamped) {
      bgColor = '#e8f5e8'
    }
    
    // ホバー効果
    if (this.hoveredCell === cellIndex && dayData.current_month) {
      bgColor = '#f0f8ff'
    }
    
    // 背景描画
    ctx.fillStyle = bgColor
    ctx.fillRect(x, y, this.cellWidth, this.cellHeight)
    
    // セルの枠線
    ctx.strokeStyle = '#dee2e6'
    ctx.lineWidth = 1
    ctx.strokeRect(x, y, this.cellWidth, this.cellHeight)
    
    // 日付テキスト
    ctx.fillStyle = dayData.current_month ? '#212529' : '#6c757d'
    ctx.font = '14px "Helvetica Neue", Arial, sans-serif'
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    ctx.fillText(dayData.date_day, x + 8, y + 8)
    
    // 今日のマーク
    if (dayData.today) {
      ctx.fillStyle = '#0d6efd'
      ctx.font = '10px "Helvetica Neue", Arial, sans-serif'
      ctx.textAlign = 'right'
      ctx.fillText('今日', x + this.cellWidth - 8, y + 8)
    }
    
    // スタンプマーク
    if (dayData.stamped) {
      this.drawStampMark(ctx, x, y, dayData.stamped_time)
    } else if (dayData.can_stamp) {
      this.drawStampableIndicator(ctx, x, y)
    }
  }

  drawStampMark(ctx, x, y, time) {
    const centerX = x + this.cellWidth / 2
    const centerY = y + this.cellHeight / 2
    
    // チェックマーク
    ctx.fillStyle = '#28a745'
    ctx.font = '20px "Helvetica Neue", Arial, sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText('✓', centerX, centerY)
    
    // 時間表示
    if (time) {
      ctx.fillStyle = '#6c757d'
      ctx.font = '10px "Helvetica Neue", Arial, sans-serif'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'bottom'
      ctx.fillText(time, centerX, y + this.cellHeight - 8)
    }
  }

  drawStampableIndicator(ctx, x, y) {
    const centerX = x + this.cellWidth / 2
    const centerY = y + this.cellHeight / 2
    
    // スタンプ可能な印
    if (this.hoveredCell !== null) {
      ctx.fillStyle = '#0d6efd'
      ctx.font = '12px "Helvetica Neue", Arial, sans-serif'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText('スタンプ', centerX, centerY)
    }
  }

  // データ更新時のメソッド（パフォーマンス最適化対応）
  calendarDataValueChanged() {
    console.log("Calendar data updated")
    this.scheduleRedraw()
  }

  themeValueChanged() {
    console.log(`Theme changed to: ${this.themeValue}`)
    this.scheduleRedraw()
  }

  // スタンプ更新の効率的な処理
  updateStamp(cellIndex, stampData) {
    this.pendingUpdates.push({
      type: 'stamp',
      cellIndex: cellIndex,
      data: stampData
    })
    
    this.scheduleRedraw()
  }

  // メモリ効率化: 不要なリスナーの削除
  cleanupResources() {
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId)
      this.animationFrameId = null
    }
    
    this.pendingUpdates = []
    this.animationScheduled = false
  }
}
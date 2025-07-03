module ApplicationHelper
  # 励ましメッセージ生成
  def encouragement_message(consecutive_days)
    case consecutive_days
    when 0
      "今日からスタート！ラジオ体操で健康な毎日を始めましょう💪"
    when 1
      "すばらしい！継続は力なり、明日も頑張りましょう🌟"
    when 2..6
      "#{consecutive_days}日連続達成！調子が上がってきましたね✨"
    when 7..13
      "#{consecutive_days}日連続！週間習慣が身についてきました🏆"
    when 14..29
      "#{consecutive_days}日連続は立派です！体の変化を感じませんか？💯"
    when 30..99
      "#{consecutive_days}日連続達成！あなたは真のラジオ体操マスターです🥇"
    else
      "#{consecutive_days}日連続！驚異的な継続力、素晴らしいです！👑"
    end
  end

  # 月表示用フォーマット
  def format_month_display(date)
    "#{date.year}年#{date.month}月"
  end

  # 年表示
  def format_year_display(date)
    date.year.to_s
  end

  # 月数字表示
  def format_month_number(date)
    date.month.to_s
  end

  # 日付数字表示
  def format_day_number(date)
    date.day.to_s
  end

  # スタンプ時刻表示
  def format_stamp_time(stamped_at)
    return "" unless stamped_at
    stamped_at.strftime("%H:%M")
  end

  # 今日判定
  def today?(date)
    date == Date.current
  end

  # CSS クラス動的生成
  def calendar_day_classes(day)
    classes = [ "calendar-day-content" ]
    classes << "today" if today?(day[:date])
    classes << "stamped" if day[:stamped]
    classes << "other-month" unless day[:current_month]
    classes.join(" ")
  end

  # 参加率のカラークラス
  def participation_rate_color_class(rate)
    case rate
    when 0..29
      "text-danger"
    when 30..59
      "text-warning"
    when 60..79
      "text-info"
    else
      "text-success"
    end
  end

  # ナビゲーションリンク生成
  def month_navigation_link(date, direction)
    params_hash = params.permit(:controller, :action).to_h
    params_hash.merge!(year: date.year, month: date.month)

    case direction
    when :previous
      link_to "◀ 前月", params_hash, class: "btn btn-outline-primary btn-sm"
    when :next
      link_to "次月 ▶", params_hash, class: "btn btn-outline-primary btn-sm"
    end
  end
end

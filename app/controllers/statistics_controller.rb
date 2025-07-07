class StatisticsController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_user_stats = calculate_user_statistics(current_user)
    @monthly_data = calculate_monthly_statistics(current_user)
    @yearly_data = calculate_yearly_statistics(current_user)
    @achievements = calculate_achievements(current_user)
    @motivational_message = generate_motivational_message(current_user)
  end

  def monthly
    @month = params[:month] ? Date.parse("#{params[:year]}-#{params[:month]}-01") : Date.current.to_date.beginning_of_month
    @monthly_stats = detailed_monthly_statistics(current_user, @month)
    @calendar_data = generate_monthly_calendar_data(current_user, @month)
  end

  def yearly
    @year = params[:year] ? params[:year].to_i : Date.current.to_date.year
    @yearly_stats = detailed_yearly_statistics(current_user, @year)
    @monthly_breakdown = generate_yearly_breakdown(current_user, @year)
  end

  private

  def calculate_user_statistics(user)
    current_date = Date.current.to_date
    {
      total_stamps: user.stamp_cards.count,
      consecutive_days: user.consecutive_days,
      current_month_stamps: user.stamp_cards.where(date: current_date.beginning_of_month..current_date.end_of_month).count,
      current_year_stamps: user.stamp_cards.where(date: current_date.beginning_of_year..current_date.end_of_year).count,
      participation_rate_this_month: calculate_monthly_participation_rate(user, current_date),
      participation_rate_this_year: calculate_yearly_participation_rate(user, current_date.year),
      longest_streak: calculate_longest_streak(user),
      average_participation_time: calculate_average_participation_time(user)
    }
  end

  def calculate_monthly_statistics(user)
    months_data = []
    (0..11).each do |i|
      month = i.months.ago.beginning_of_month
      stamp_count = user.stamp_cards.where(date: month..month.end_of_month).count
      participation_rate = calculate_monthly_participation_rate(user, month)

      months_data << {
        month: month,
        stamp_count: stamp_count,
        participation_rate: participation_rate,
        days_in_month: month.end_of_month.day
      }
    end
    months_data.reverse
  end

  def calculate_yearly_statistics(user)
    years_data = []
    registration_year = user.created_at.year
    (registration_year..Date.current.to_date.year).each do |year|
      year_start = Date.new(year, 1, 1)
      year_end = Date.new(year, 12, 31)
      stamp_count = user.stamp_cards.where(date: year_start..year_end).count
      participation_rate = calculate_yearly_participation_rate(user, year)

      years_data << {
        year: year,
        stamp_count: stamp_count,
        participation_rate: participation_rate,
        days_in_year: year_end.yday
      }
    end
    years_data
  end

  def calculate_achievements(user)
    # 新しいバッジを自動チェック・付与
    newly_earned_badges = user.check_and_award_new_badges!

    # ユーザーが獲得済みのバッジを取得（最新10件）
    earned_badges = user.earned_badges.first(10)

    # バッジ情報をachievements形式に変換
    achievements = earned_badges.filter_map do |badge|
      next unless badge&.respond_to?(:badge_type) && badge&.respond_to?(:name)

      {
        type: badge.badge_type,
        title: badge.name,
        description: badge.description,
        icon: badge.icon,
        earned_at: user.earned_badge_at(badge)
      }
    end

    # 新しく獲得したバッジがあれば、フラッシュメッセージで通知
    if newly_earned_badges.any?
      newly_earned_badges.each do |badge|
        next unless badge&.respond_to?(:name)

        flash[:badge_earned] ||= []
        flash[:badge_earned] << {
          name: badge.name,
          description: badge.description,
          icon: badge.icon
        }
      end
    end

    achievements
  rescue => e
    Rails.logger.error "Error in calculate_achievements: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    []
  end

  def generate_motivational_message(user)
    consecutive_days = user.consecutive_days
    total_stamps = user.stamp_cards.count
    participation_rate_this_month = calculate_monthly_participation_rate(user, Date.current.to_date)

    messages = []

    # 基本メッセージ
    messages << "今日も一日、健康的に過ごしましょう！"
    messages << "継続は力なり。健康習慣を大切にしましょう。"
    messages << "ラジオ体操で素敵な一日をスタートしませんか？"

    # 連続参加に基づくメッセージ
    current_date = Date.current.to_date
    if consecutive_days == 0
      if user.stamp_cards.exists?(date: current_date - 1.day)
        messages << "昨日参加されましたね！今日も続けてみませんか？"
      else
        messages << "新しいスタートを切りましょう！今日からラジオ体操を始めませんか？"
      end
    elsif consecutive_days < 7
      messages << "#{consecutive_days}日連続参加中です！一週間継続まであと#{7 - consecutive_days}日です。"
    elsif consecutive_days < 30
      messages << "素晴らしい！#{consecutive_days}日連続参加中です。継続は力なりですね！"
    else
      messages << "驚異的！#{consecutive_days}日連続参加は本当に素晴らしいです！"
    end

    # 参加率に基づくメッセージ
    if participation_rate_this_month >= 80
      messages << "今月の参加率#{participation_rate_this_month.round(1)}%は素晴らしい成績です！"
    elsif participation_rate_this_month >= 50
      messages << "今月の参加率#{participation_rate_this_month.round(1)}%、良いペースです！"
    elsif participation_rate_this_month < 30
      messages << "今月はまた新しいチャンスです。一歩一歩進んでいきましょう！"
    end

    # 総参加数に基づくメッセージ
    if total_stamps >= 100
      messages << "通算#{total_stamps}回参加は立派な実績です！健康習慣が身についていますね。"
    elsif total_stamps >= 30
      messages << "#{total_stamps}回の参加、確実に習慣化されています！"
    end

    # ランダムに一つのメッセージを選択
    messages.sample || "今日も一日、健康的に過ごしましょう！"
  end

  def detailed_monthly_statistics(user, month)
    month_start = month.to_date.beginning_of_month
    month_end = month.to_date.end_of_month

    stamps_in_month = user.stamp_cards.where(date: month_start..month_end)

    # 平均時間の計算を安全に行う
    average_time_minutes = stamps_in_month.average("EXTRACT(HOUR FROM stamped_at) * 60 + EXTRACT(MINUTE FROM stamped_at)")
    safe_average_time = if average_time_minutes.present?
      # 小数点を含む場合も考慮して整数分に変換
      total_minutes = average_time_minutes.to_f.round
      # 有効な時間範囲内（0-1439分）であることを確認
      total_minutes = [ [ total_minutes, 0 ].max, 1439 ].min
      total_minutes
    else
      nil
    end

    {
      month: month,
      total_stamps: stamps_in_month.count,
      days_in_month: month_end.day,
      participation_rate: calculate_monthly_participation_rate(user, month),
      stamps_by_week: calculate_weekly_breakdown(stamps_in_month, month),
      average_time: safe_average_time,
      earliest_time: stamps_in_month.minimum(:stamped_at)&.strftime("%H:%M"),
      latest_time: stamps_in_month.maximum(:stamped_at)&.strftime("%H:%M")
    }
  end

  def detailed_yearly_statistics(user, year)
    year_start = Date.new(year, 1, 1)
    year_end = Date.new(year, 12, 31)

    stamps_in_year = user.stamp_cards.where(date: year_start..year_end)

    {
      year: year,
      total_stamps: stamps_in_year.count,
      days_in_year: year_end.yday,
      participation_rate: calculate_yearly_participation_rate(user, year),
      monthly_breakdown: (1..12).map { |month|
        month_date = Date.new(year, month, 1)
        {
          month: month,
          month_name: month_date.strftime("%B"),
          stamp_count: stamps_in_year.where(date: month_date.beginning_of_month..month_date.end_of_month).count,
          participation_rate: calculate_monthly_participation_rate(user, month_date)
        }
      },
      longest_streak_in_year: calculate_longest_streak_in_period(user, year_start, year_end),
      most_active_month: find_most_active_month(stamps_in_year, year)
    }
  end

  def generate_monthly_calendar_data(user, month)
    month_start = month.to_date.beginning_of_month
    month_end = month.to_date.end_of_month

    stamps = user.stamp_cards.where(date: month_start..month_end).pluck(:date, :stamped_at).to_h

    calendar_data = []

    # カレンダーの開始日（日曜日から開始）
    start_date = month_start.beginning_of_week(:sunday)
    end_date = month_end.end_of_week(:sunday)

    (start_date..end_date).each_slice(7) do |week|
      week_data = week.map do |date|
        {
          date: date,
          current_month: date.month == month.month,
          stamped: stamps.key?(date),
          stamped_time: stamps[date]&.strftime("%H:%M"),
          today: date == Date.current.to_date
        }
      end
      calendar_data << week_data
    end

    calendar_data
  end

  def generate_yearly_breakdown(user, year)
    (1..12).map do |month|
      month_date = Date.new(year, month, 1)
      month_start = month_date.beginning_of_month
      month_end = month_date.end_of_month

      stamp_count = user.stamp_cards.where(date: month_start..month_end).count

      {
        month: month,
        month_name: month_date.strftime("%B"),
        stamp_count: stamp_count,
        participation_rate: calculate_monthly_participation_rate(user, month_date),
        days_in_month: month_end.day
      }
    end
  end

  def calculate_monthly_participation_rate(user, month)
    month_start = month.to_date.beginning_of_month
    month_end = [ month.to_date.end_of_month, Date.current.to_date ].min

    days_passed = (month_start..month_end).count
    stamps_count = user.stamp_cards.where(date: month_start..month_end).count

    return 0.0 if days_passed == 0
    (stamps_count.to_f / days_passed * 100).round(2)
  end

  def calculate_yearly_participation_rate(user, year)
    year_start = Date.new(year, 1, 1)
    year_end = [ Date.new(year, 12, 31), Date.current.to_date ].min

    days_passed = (year_start..year_end).count
    stamps_count = user.stamp_cards.where(date: year_start..year_end).count

    return 0.0 if days_passed == 0
    (stamps_count.to_f / days_passed * 100).round(2)
  end

  def calculate_longest_streak(user)
    return 0 if user.stamp_cards.empty?

    dates = user.stamp_cards.order(:date).pluck(:date)
    max_streak = 0
    current_streak = 1

    (1...dates.length).each do |i|
      if dates[i] == dates[i-1] + 1.day
        current_streak += 1
        max_streak = [ max_streak, current_streak ].max
      else
        current_streak = 1
      end
    end

    [ max_streak, current_streak ].max
  end

  def calculate_longest_streak_in_period(user, start_date, end_date)
    dates = user.stamp_cards.where(date: start_date..end_date).order(:date).pluck(:date)
    return 0 if dates.empty?

    max_streak = 0
    current_streak = 1

    (1...dates.length).each do |i|
      if dates[i] == dates[i-1] + 1.day
        current_streak += 1
        max_streak = [ max_streak, current_streak ].max
      else
        current_streak = 1
      end
    end

    [ max_streak, current_streak ].max
  end

  def calculate_average_participation_time(user)
    return nil if user.stamp_cards.empty?

    times = user.stamp_cards.pluck(:stamped_at).map do |time|
      time.hour * 60 + time.min
    end

    avg_minutes = times.sum / times.length
    Time.new(2000, 1, 1, avg_minutes / 60, avg_minutes % 60).strftime("%H:%M")
  end

  def calculate_weekly_breakdown(stamps, month)
    weeks = []
    month_start = month.to_date.beginning_of_month
    current_date = month_start.beginning_of_week(:sunday)

    while current_date <= month.to_date.end_of_month
      week_end = [ current_date.end_of_week(:sunday), month.to_date.end_of_month ].min
      week_stamps = stamps.where(date: current_date..week_end).count

      weeks << {
        start_date: current_date,
        end_date: week_end,
        stamp_count: week_stamps,
        week_number: ((current_date - month_start) / 7).to_i + 1
      }

      current_date = current_date.next_week(:sunday)
    end

    weeks
  end

  def find_most_active_month(stamps, year)
    monthly_counts = stamps.group("EXTRACT(MONTH FROM date)").count
    return nil if monthly_counts.empty?

    most_active_month_num = monthly_counts.max_by { |month, count| count }[0].to_i
    Date.new(year, most_active_month_num, 1).strftime("%B")
  end
end

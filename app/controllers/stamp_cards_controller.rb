class StampCardsController < ApplicationController
  before_action :authenticate_user!

  def index
    # 月間ナビゲーション処理
    @current_month = parse_month_params
    @stamp_cards = current_user.stamp_cards.includes(:user).order(date: :desc)
    @calendar_days = generate_calendar_days(@current_month)

    # 基本統計情報
    @stamped_today = current_user.stamped_today?
    @consecutive_days = current_user.consecutive_days
    @total_stamps = current_user.total_stamps

    # 月間統計情報
    @monthly_stamps = current_user.stamp_cards.where(
      date: @current_month.beginning_of_month..@current_month.end_of_month
    ).count
    @monthly_participation_rate = calculate_monthly_participation_rate(@current_month)

    # ナビゲーション用の前月・次月
    @previous_month = @current_month - 1.month
    @next_month = @current_month + 1.month
  end

  def create
    if current_user.stamped_today?
      redirect_to stamp_cards_path, alert: "今日はすでにスタンプを押しています。"
      return
    end

    unless within_participation_time?
      start_time = AdminSetting.participation_start_time
      end_time = AdminSetting.participation_end_time
      redirect_to stamp_cards_path, alert: "スタンプは#{start_time}〜#{end_time}の間のみ押すことができます。"
      return
    end

    begin
      current_user.stamp_today!
      redirect_to stamp_cards_path, notice: "スタンプを押しました！"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to stamp_cards_path, alert: "エラーが発生しました: #{e.message}"
    end
  end

  private

  def within_participation_time?
    now = Time.current
    start_time_str = AdminSetting.participation_start_time
    end_time_str = AdminSetting.participation_end_time

    start_time = Time.current.beginning_of_day + parse_time_string(start_time_str).seconds_since_midnight
    end_time = Time.current.beginning_of_day + parse_time_string(end_time_str).seconds_since_midnight

    now.between?(start_time, end_time)
  end

  def parse_time_string(time_str)
    Time.parse(time_str)
  rescue ArgumentError
    Time.parse("06:00")
  end

  def generate_calendar_days(month_start)
    days = []
    current_date = month_start.beginning_of_week(:sunday)

    5.times do
      week = []
      7.times do
        stamp_card = current_user.stamp_cards.find_by(date: current_date)
        week << {
          date: current_date,
          stamped: stamp_card.present?,
          stamped_at: stamp_card&.stamped_at,
          current_month: current_date.month == month_start.month
        }
        current_date += 1.day
      end
      days << week
    end

    days
  end

  def parse_month_params
    if params[:year].present? && params[:month].present?
      begin
        Date.new(params[:year].to_i, params[:month].to_i, 1)
      rescue ArgumentError
        Date.current.beginning_of_month
      end
    else
      Date.current.beginning_of_month
    end
  end

  def calculate_monthly_participation_rate(month)
    month_start = month.beginning_of_month
    month_end = month.end_of_month
    total_days = (month_start..month_end).count
    participated_days = current_user.stamp_cards.where(
      date: month_start..month_end
    ).count

    return 0 if total_days.zero?

    ((participated_days.to_f / total_days) * 100).round(1)
  end
end

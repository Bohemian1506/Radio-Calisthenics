class StampCardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @stamp_cards = current_user.stamp_cards.includes(:user).order(date: :desc)
    @current_month = Date.current.beginning_of_month
    @calendar_days = generate_calendar_days(@current_month)
    @stamped_today = current_user.stamped_today?
    @consecutive_days = current_user.consecutive_days
    @total_stamps = current_user.total_stamps
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

    6.times do
      week = []
      7.times do
        week << {
          date: current_date,
          stamped: current_user.stamp_cards.exists?(date: current_date),
          current_month: current_date.month == month_start.month
        }
        current_date += 1.day
      end
      days << week
    end

    days
  end
end

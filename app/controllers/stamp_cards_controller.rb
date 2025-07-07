class StampCardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @month = parse_month_params
    @calendar_data = generate_calendar_data(@month)
    @monthly_stats = calculate_monthly_stats(@month)
    @user_stats = calculate_user_stats
  end

  def monthly
    @month = parse_month_params
    redirect_to stamp_cards_path(year: @month.year, month: @month.month)
  end

  def create
    @stamp_card = current_user.stamp_cards.build(stamp_card_params)
    @stamp_card.date = Date.current if @stamp_card.date.blank?
    @stamp_card.stamped_at = Time.current if @stamp_card.stamped_at.blank?

    if @stamp_card.save
      redirect_to stamp_cards_path, notice: "今日のスタンプを押しました！"
    else
      redirect_to stamp_cards_path, alert: "スタンプの作成に失敗しました。#{@stamp_card.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @stamp_card = current_user.stamp_cards.find(params[:id])

    if @stamp_card.destroy
      redirect_to stamp_cards_path, notice: "スタンプを削除しました。"
    else
      redirect_to stamp_cards_path, alert: "スタンプの削除に失敗しました。"
    end
  end



  private


  def stamp_card_params
    params.require(:stamp_card).permit(:date, :stamped_at)
  end

  def parse_month_params
    if params[:year].present? && params[:month].present?
      begin
        year = params[:year].to_i
        month = params[:month].to_i

        # Validate reasonable year range
        if year < 2020 || year > Date.current.year + 1
          Rails.logger.warn "Invalid year parameter: #{year} for user #{current_user&.id}"
          return Date.current.beginning_of_month
        end

        # Validate month range
        if month < 1 || month > 12
          Rails.logger.warn "Invalid month parameter: #{month} for user #{current_user&.id}"
          return Date.current.beginning_of_month
        end

        Date.new(year, month, 1)
      rescue ArgumentError => e
        Rails.logger.warn "Date parsing error: #{e.message} for params #{params[:year]}/#{params[:month]}"
        Date.current.beginning_of_month
      end
    else
      Date.current.beginning_of_month
    end
  end

  def generate_calendar_data(month)
    month_start = month.beginning_of_month
    month_end = month.end_of_month

    # ユーザーのスタンプデータを取得
    stamps = current_user.stamp_cards.where(date: month_start..month_end)
                        .pluck(:date, :stamped_at).to_h

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
          today: date == Date.current,
          can_stamp: !stamps.key?(date) && date.month == month.month
        }
      end
      calendar_data << week_data
    end

    calendar_data
  end

  def calculate_monthly_stats(month)
    month_start = month.beginning_of_month
    month_end = month.end_of_month

    stamps_in_month = current_user.stamp_cards.where(date: month_start..month_end)
    days_in_month = month_end.day
    days_passed = [ month_end, Date.current ].min.day

    {
      month: month,
      total_stamps: stamps_in_month.count,
      days_in_month: days_in_month,
      days_passed: days_passed,
      participation_rate: days_passed > 0 ? (stamps_in_month.count.to_f / days_passed * 100).round(1) : 0.0,
      can_stamp_today: current_user.can_stamp_today? && month.month == Date.current.month
    }
  end

  def calculate_user_stats
    {
      total_stamps: current_user.total_stamps,
      consecutive_days: current_user.consecutive_days,
      longest_streak: current_user.longest_streak,
      stamps_this_month: current_user.stamps_this_month,
      stamps_this_year: current_user.stamps_this_year,
      average_time: current_user.average_participation_time
    }
  end
end

class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_stamps = 0 # StampCard.count # TODO: スタンプ機能復活時に有効化
    @today_stamps = 0 # StampCard.where(date: Date.current).count # TODO: スタンプ機能復活時に有効化
    @active_users = 0 # User.joins(:stamp_cards)
    #     .where(stamp_cards: { date: 1.week.ago..Date.current })
    #     .distinct
    #     .count # TODO: スタンプ機能復活時に有効化

    @recent_stamps = [] # StampCard.includes(:user)
    #         .order(created_at: :desc)
    #         .limit(10) # TODO: スタンプ機能復活時に有効化

    @daily_stats = generate_daily_stats
  end

  private

  def generate_daily_stats
    7.days.ago.to_date.upto(Date.current).map do |date|
      {
        date: date,
        count: 0 # StampCard.where(date: date).count # TODO: スタンプ機能復活時に有効化
      }
    end
  end
end

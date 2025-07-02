class Admin::DashboardController < Admin::BaseController
  def index
    @total_users = User.count
    @total_stamps = StampCard.count
    @today_stamps = StampCard.where(date: Date.current).count
    @active_users = User.joins(:stamp_cards)
                       .where(stamp_cards: { date: 1.week.ago..Date.current })
                       .distinct
                       .count

    @recent_stamps = StampCard.includes(:user)
                             .order(created_at: :desc)
                             .limit(10)

    @daily_stats = generate_daily_stats
  end

  private

  def generate_daily_stats
    7.days.ago.to_date.upto(Date.current).map do |date|
      {
        date: date,
        count: StampCard.where(date: date).count
      }
    end
  end
end

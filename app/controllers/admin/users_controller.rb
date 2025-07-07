class Admin::UsersController < Admin::BaseController
  def index
    @users = User.includes(:stamp_cards)
                 .order(:created_at)

    @users_with_stats = @users.map do |user|
      {
        user: user,
        total_stamps: user.total_stamps,
        consecutive_days: user.consecutive_days,
        last_stamp: user.stamp_cards.order(:date).last&.date
      }
    end
  end

  def show
    @user = User.find(params[:id])
    @stamp_cards = @user.stamp_cards.includes(:user).order(date: :desc)
    @monthly_stats = generate_monthly_stats(@user)
  end

  private

  def generate_monthly_stats(user)
    12.times.map do |i|
      month = i.months.ago.beginning_of_month
      {
        month: month,
        count: user.stamp_cards.where(
          date: month..month.end_of_month
        ).count
      }
    end.reverse
  end
end

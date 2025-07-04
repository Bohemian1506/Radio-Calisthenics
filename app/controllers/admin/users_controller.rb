class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(:created_at)
                 .page(params[:page])
    # User.includes(:stamp_cards) # TODO: スタンプ機能復活時に有効化

    @users_with_stats = @users.map do |user|
      {
        user: user,
        total_stamps: 0, # user.total_stamps, # TODO: スタンプ機能復活時に有効化
        consecutive_days: 0, # user.consecutive_days, # TODO: スタンプ機能復活時に有効化
        last_stamp: nil # user.stamp_cards.order(:date).last&.date # TODO: スタンプ機能復活時に有効化
      }
    end
  end

  def show
    @user = User.find(params[:id])
    @stamp_cards = [] # @user.stamp_cards.includes(:user).order(date: :desc) # TODO: スタンプ機能復活時に有効化
    @monthly_stats = generate_monthly_stats(@user)
  end

  private

  def generate_monthly_stats(user)
    12.times.map do |i|
      month = i.months.ago.beginning_of_month
      {
        month: month,
        count: 0 # user.stamp_cards.where(
        #   date: month.beginning_of_month..month.end_of_month
        # ).count # TODO: スタンプ機能復活時に有効化
      }
    end.reverse
  end
end

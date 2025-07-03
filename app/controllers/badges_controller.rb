class BadgesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_badge, only: [ :show ]

  def index
    @all_badges = Badge.active.ordered
    @user_badges = current_user.earned_badges.includes(:user_badges)
    @earned_badge_ids = current_user.badges.pluck(:id)

    # バッジ獲得統計
    @badge_stats = {
      total_earned: current_user.badge_count,
      total_available: @all_badges.count,
      completion_rate: calculate_completion_rate,
      latest_badge: current_user.latest_badge,
      by_type: calculate_badges_by_type
    }
  end

  def show
    @user_badge = current_user.user_badges.find_by(badge: @badge)
    @is_earned = @user_badge.present?
    @earned_at = @user_badge&.earned_at
    @can_earn = @badge.can_be_earned_by?(current_user) unless @is_earned

    # 同じタイプの他のバッジ
    @related_badges = Badge.active.by_type(@badge.badge_type).where.not(id: @badge.id).ordered.limit(5)
  end

  private

  def set_badge
    @badge = Badge.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to badges_path, alert: "バッジが見つかりませんでした。"
  end

  def calculate_completion_rate
    return 0 if @all_badges.empty?
    (current_user.badge_count.to_f / @all_badges.count * 100).round(1)
  end

  def calculate_badges_by_type
    Badge::BADGE_TYPES.keys.map do |type|
      earned_count = current_user.badge_count_by_type(type.to_s)
      total_count = @all_badges.by_type(type.to_s).count

      {
        type: type,
        type_name: Badge::BADGE_TYPES[type],
        earned: earned_count,
        total: total_count,
        percentage: total_count > 0 ? (earned_count.to_f / total_count * 100).round(1) : 0
      }
    end
  end
end

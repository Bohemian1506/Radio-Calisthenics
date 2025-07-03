class CheckUserBadgesJob < ApplicationJob
  queue_as :default

  def perform(user)
    return unless user.is_a?(User)

    # ユーザーの新しいバッジをチェック・付与
    newly_earned_badges = user.check_and_award_new_badges!

    # 新しく獲得したバッジをログに記録
    if newly_earned_badges.any?
      badge_names = newly_earned_badges.map(&:name).join(", ")
      Rails.logger.info "User #{user.id} earned new badges: #{badge_names}"
    end

    newly_earned_badges
  rescue => e
    Rails.logger.error "Failed to check badges for user #{user&.id}: #{e.message}"
    raise e
  end
end
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges

  def admin?
    admin
  end

  # バッジ関連メソッド
  def earned_badges
    user_badges.includes(:badge).order(earned_at: :desc).map(&:badge)
  end

  def earned_badges_by_type(badge_type)
    badges.joins(:user_badges).where(
      user_badges: { user: self },
      badges: { badge_type: badge_type }
    ).order("user_badges.earned_at DESC")
  end

  def latest_badge
    user_badges.includes(:badge).order(:earned_at).last&.badge
  end

  def badge_count
    user_badges.count
  end

  def badge_count_by_type(badge_type)
    user_badges.joins(:badge).where(badges: { badge_type: badge_type }).count
  end

  def check_and_award_new_badges!
    newly_earned = []

    Badge.active.find_each do |badge|
      if badge.can_be_earned_by?(self)
        user_badge = UserBadge.award_badge_to_user(self, badge)
        newly_earned << badge if user_badge
      end
    end

    newly_earned
  end

  def has_badge?(badge)
    badges.include?(badge)
  end

  def earned_badge_at(badge)
    user_badges.find_by(badge: badge)&.earned_at
  end
end

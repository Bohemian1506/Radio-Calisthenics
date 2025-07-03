class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge

  validates :user_id, uniqueness: { scope: :badge_id }
  validates :earned_at, presence: true

  scope :recent, -> { order(earned_at: :desc) }
  scope :by_badge_type, ->(type) { joins(:badge).where(badges: { badge_type: type }) }

  before_validation :set_earned_at, on: :create

  def self.award_badge_to_user(user, badge)
    return false if user.badges.include?(badge)
    return false unless badge.can_be_earned_by?(user)

    create!(user: user, badge: badge)
  end

  private

  def set_earned_at
    self.earned_at ||= Time.current
  end
end
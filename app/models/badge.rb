class Badge < ApplicationRecord
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :icon, presence: true
  validates :badge_type, presence: true
  validates :conditions, presence: true

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(badge_type: type) }
  scope :ordered, -> { order(:sort_order, :name) }

  # バッジタイプ定数
  BADGE_TYPES = {
    streak: "連続参加",
    milestone: "総参加数",
    perfect_month: "月間皆勤",
    early_bird: "早起き",
    weekend_warrior: "週末参加",
    seasonal: "季節限定",
    special: "特別"
  }.freeze

  def self.badge_types
    BADGE_TYPES
  end

  def earned_by?(user)
    user_badges.exists?(user: user)
  end

  def earned_at_for(user)
    user_badges.find_by(user: user)&.earned_at
  end

  def can_be_earned_by?(user)
    return false unless active?
    return false if earned_by?(user)

    check_conditions(user)
  end

  private

  def check_conditions(user)
    return false unless conditions.is_a?(Hash)

    case badge_type
    when "streak"
      check_streak_conditions(user)
    when "milestone"
      check_milestone_conditions(user)
    when "perfect_month"
      check_perfect_month_conditions(user)
    when "early_bird"
      check_early_bird_conditions(user)
    when "weekend_warrior"
      check_weekend_warrior_conditions(user)
    when "seasonal"
      check_seasonal_conditions(user)
    else
      false
    end
  end

  def check_streak_conditions(user)
    # スタンプカード機能が削除されたため、バッジは一時的に取得不可
    false
  end

  def check_milestone_conditions(user)
    # スタンプカード機能が削除されたため、バッジは一時的に取得不可
    false
  end

  def check_perfect_month_conditions(user)
    # スタンプカード機能が削除されたため、バッジは一時的に取得不可
    false
  end

  def check_early_bird_conditions(user)
    # スタンプカード機能が削除されたため、バッジは一時的に取得不可
    false
  end

  def check_weekend_warrior_conditions(user)
    # スタンプカード機能が削除されたため、バッジは一時的に取得不可
    false
  end

  def check_seasonal_conditions(user)
    # スタンプカード機能が削除されたため、バッジは一時的に取得不可
    false
  end

  def get_season_date_range(season)
    current_year = Date.current.year

    case season
    when "spring"
      Date.new(current_year, 3, 1)..Date.new(current_year, 5, 31)
    when "summer"
      Date.new(current_year, 6, 1)..Date.new(current_year, 8, 31)
    when "autumn"
      Date.new(current_year, 9, 1)..Date.new(current_year, 11, 30)
    when "winter"
      Date.new(current_year, 12, 1)..Date.new(current_year + 1, 2, 28)
    else
      nil
    end
  end
end

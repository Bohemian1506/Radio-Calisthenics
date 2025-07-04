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
    return false unless conditions["days"]

    required_days = conditions["days"].to_i
    user.consecutive_days >= required_days
  end

  def check_milestone_conditions(user)
    return false unless conditions["total_stamps"]

    required_stamps = conditions["total_stamps"].to_i
    user.total_stamps >= required_stamps
  end

  def check_perfect_month_conditions(user)
    return false unless conditions["months"]

    required_months = conditions["months"].to_i
    perfect_months = 0

    # 過去12ヶ月をチェック
    (0..11).each do |i|
      month = i.months.ago.beginning_of_month
      month_end = month.end_of_month

      # その月の日数を取得
      days_in_month = month_end.day

      # その月のスタンプ数を取得
      stamps_in_month = user.stamp_cards.where(date: month..month_end).count

      perfect_months += 1 if stamps_in_month == days_in_month
    end

    perfect_months >= required_months
  end

  def check_early_bird_conditions(user)
    return false unless conditions["hour"] && conditions["count"]

    required_hour = conditions["hour"].to_i
    required_count = conditions["count"].to_i

    early_stamps = user.stamp_cards.where(
      "EXTRACT(HOUR FROM stamped_at) <= ?", required_hour
    ).count

    early_stamps >= required_count
  end

  def check_weekend_warrior_conditions(user)
    return false unless conditions["weekends"]

    required_weekends = conditions["weekends"].to_i
    weekend_stamps = 0

    user.stamp_cards.each do |stamp|
      weekend_stamps += 1 if stamp.date.saturday? || stamp.date.sunday?
    end

    weekend_stamps >= required_weekends
  end

  def check_seasonal_conditions(user)
    return false unless conditions["season"] && conditions["stamps"]

    season = conditions["season"]
    required_stamps = conditions["stamps"].to_i
    date_range = get_season_date_range(season)

    return false unless date_range

    seasonal_stamps = user.stamp_cards.where(date: date_range).count
    seasonal_stamps >= required_stamps
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

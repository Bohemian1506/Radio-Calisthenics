class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :stamp_cards, dependent: :destroy
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

  # スタンプカード関連メソッド
  def consecutive_days
    return 0 if stamp_cards.empty?

    current_date = Date.current
    consecutive = 0

    # 今日から過去に向かって連続日数をカウント
    while stamp_cards.exists?(date: current_date)
      consecutive += 1
      current_date -= 1.day
    end

    consecutive
  end

  def total_stamps
    stamp_cards.count
  end

  def stamps_this_month
    stamp_cards.for_month(Date.current).count
  end

  def stamps_this_year
    stamp_cards.for_year(Date.current.year).count
  end

  def longest_streak
    return 0 if stamp_cards.empty?

    dates = stamp_cards.order(:date).pluck(:date)
    max_streak = 0
    current_streak = 1

    (1...dates.length).each do |i|
      if dates[i] == dates[i-1] + 1.day
        current_streak += 1
        max_streak = [ max_streak, current_streak ].max
      else
        current_streak = 1
      end
    end

    [ max_streak, current_streak ].max
  end

  def average_participation_time
    return nil if stamp_cards.empty?

    times = stamp_cards.pluck(:stamped_at).map do |time|
      time.hour * 60 + time.min
    end

    avg_minutes = times.sum / times.length
    Time.new(2000, 1, 1, avg_minutes / 60, avg_minutes % 60).strftime("%H:%M")
  end

  def stamped_today?
    stamp_cards.exists?(date: Date.current)
  end

  def can_stamp_today?
    !stamped_today?
  end
end

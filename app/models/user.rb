class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :stamp_cards, dependent: :destroy

  def admin?
    admin
  end

  def stamped_today?
    StampCard.stamped_today?(self)
  end

  def stamp_today!
    StampCard.create_stamp!(self)
  end

  def consecutive_days
    return 0 if stamp_cards.empty?

    consecutive_count = 0
    current_date = Date.current

    loop do
      break unless stamp_cards.exists?(date: current_date)
      consecutive_count += 1
      current_date -= 1.day
    end

    consecutive_count
  end

  def total_stamps
    stamp_cards.count
  end
end

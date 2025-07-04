class StampCard < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :stamped_at, presence: true
  validates :user_id, presence: true

  scope :for_user, ->(user) { where(user: user) }
  scope :for_date, ->(date) { where(date: date) }
  scope :for_month, ->(month) { where(date: month.beginning_of_month..month.end_of_month) }
  scope :for_year, ->(year) { where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31)) }
  scope :ordered, -> { order(:date) }
  scope :recent, -> { order(stamped_at: :desc) }

  def self.for_date_range(start_date, end_date)
    where(date: start_date..end_date)
  end

  def morning_exercise?
    stamped_at.hour < 12
  end

  def evening_exercise?
    stamped_at.hour >= 18
  end
end

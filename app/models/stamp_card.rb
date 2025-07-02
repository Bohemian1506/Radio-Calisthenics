class StampCard < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :stamped_at, presence: true

  scope :for_date, ->(date) { where(date: date) }
  scope :for_user, ->(user) { where(user: user) }

  def self.stamped_today?(user)
    exists?(user: user, date: Date.current)
  end

  def self.create_stamp!(user)
    create!(
      user: user,
      date: Date.current,
      stamped_at: Time.current
    )
  end
end

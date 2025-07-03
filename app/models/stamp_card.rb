class StampCard < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :stamped_at, presence: true

  scope :for_date, ->(date) { where(date: date) }
  scope :for_user, ->(user) { where(user: user) }

  # スタンプ作成後にバッジチェックを実行
  after_create :check_user_badges

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

  private

  def check_user_badges
    if Rails.env.development?
      # 開発環境では同期的に実行（デバッグしやすくするため）
      user.check_and_award_new_badges!
    else
      # 本番環境では非同期で実行（パフォーマンス向上のため）
      CheckUserBadgesJob.perform_later(user)
    end
  rescue => e
    # バッジチェックでエラーが発生してもスタンプ作成を妨げない
    Rails.logger.error "Badge check failed for user #{user.id}: #{e.message}"
  end
end

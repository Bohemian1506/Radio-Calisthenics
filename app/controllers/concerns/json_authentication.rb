module JsonAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :check_json_authentication
  end

  private

  def check_json_authentication
    if request.format.json? && !user_signed_in?
      render json: {
        status: "error",
        message: "認証が必要です。ログインしてください。"
      }, status: :unauthorized
    end
  end
end

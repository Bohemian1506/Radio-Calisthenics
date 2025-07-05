class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Ensure JSON response for Ajax requests even on errors
  rescue_from StandardError do |exception|
    if request.format.json?
      Rails.logger.error "Unhandled error in JSON request: #{exception.message}"
      Rails.logger.error exception.backtrace.join("\n") if Rails.env.development?

      render json: {
        status: "error",
        message: "予期しないエラーが発生しました。しばらく時間をおいて再度お試しください。"
      }, status: :internal_server_error
    else
      # Re-raise for normal HTML requests to use default error handling
      raise exception
    end
  end

  # Handle authentication errors for JSON requests
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    if request.format.json?
      render json: {
        status: "error",
        message: "セッションが期限切れです。ページを再読み込みしてください。"
      }, status: :unprocessable_entity
    else
      raise exception
    end
  end
end

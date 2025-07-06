class StampCardsController < ApplicationController
  include JsonAuthentication

  before_action :authenticate_user!, unless: -> { request.format.json? }
  before_action :ensure_json_format, only: [ :generate_image ], if: -> { request.format.json? }

  def index
    @month = parse_month_params
    @calendar_data = generate_calendar_data(@month)
    @monthly_stats = calculate_monthly_stats(@month)
    @user_stats = calculate_user_stats
  end

  def monthly
    @month = parse_month_params
    redirect_to stamp_cards_path(year: @month.year, month: @month.month)
  end

  def create
    @stamp_card = current_user.stamp_cards.build(stamp_card_params)
    @stamp_card.date = Date.current if @stamp_card.date.blank?
    @stamp_card.stamped_at = Time.current if @stamp_card.stamped_at.blank?

    if @stamp_card.save
      redirect_to stamp_cards_path, notice: "今日のスタンプを押しました！"
    else
      redirect_to stamp_cards_path, alert: "スタンプの作成に失敗しました。#{@stamp_card.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @stamp_card = current_user.stamp_cards.find(params[:id])

    if @stamp_card.destroy
      redirect_to stamp_cards_path, notice: "スタンプを削除しました。"
    else
      redirect_to stamp_cards_path, alert: "スタンプの削除に失敗しました。"
    end
  end

  def generate_image
    @month = parse_month_params

    # Debug logging
    Rails.logger.info "Generate image request - Format: #{request.format}, XHR: #{request.xhr?}, Accept: #{request.headers['Accept']}"
    Rails.logger.info "Request params: #{params.inspect}"

    begin
      # Validate that user has stamps for the requested month
      stamps_count = current_user.stamp_cards.where(date: @month.beginning_of_month..@month.end_of_month).count
      if stamps_count == 0
        raise StandardError, "指定された月にスタンプデータがありません"
      end

      # Parse theme and image format parameters (use image_format to avoid conflict with request format)
      theme = params[:theme]&.to_sym || :default
      image_format = params[:image_format]&.to_sym || :png

      service = StampCardImageService.new(
        user: current_user,
        year: @month.year,
        month: @month.month,
        theme: theme,
        format: image_format
      )

      image = service.generate

      # Generate temporary file for download with error handling
      file_extension = image_format == :pdf ? ".pdf" : ".png"
      temp_file = Tempfile.new([ "stamp_card_#{current_user.id}_#{@month.year}_#{@month.month}", file_extension ])
      service.save_to_file(temp_file.path)

      # Verify file was created successfully
      unless File.exist?(temp_file.path) && File.size(temp_file.path) > 0
        raise StandardError, "画像ファイルの作成に失敗しました"
      end

      # Store temp file path in session for download action
      session[:stamp_card_image_path] = temp_file.path

      # Success response
      if request.format.json? || request.xhr?
        render json: { status: "success", message: "画像を生成しました" }
      else
        redirect_to stamp_cards_path(year: @month.year, month: @month.month), notice: "スタンプカード画像を生成しました"
      end
    rescue ActionController::UnknownFormat => e
      Rails.logger.error "Format error in image generation: #{e.message}"
      Rails.logger.error "Request format: #{request.format}, XHR: #{request.xhr?}, Path: #{request.path}"
      Rails.logger.error "Headers: #{request.headers.to_h.select { |k, v| k.start_with?('HTTP_') }}"

      error_message = "リクエスト形式が不正です。"

      if request.xhr?
        render json: { status: "error", message: error_message }, status: :not_acceptable
      else
        redirect_to stamp_cards_path(year: @month.year, month: @month.month), alert: error_message
      end
    rescue ArgumentError => e
      Rails.logger.error "Image generation parameter error: #{e.message}"
      error_message = "パラメータエラー: #{e.message}"

      if request.format.json? || request.xhr?
        render json: { status: "error", message: error_message }, status: :bad_request
      else
        redirect_to stamp_cards_path(year: @month.year, month: @month.month), alert: error_message
      end
    rescue StandardError => e
      Rails.logger.error "Image generation failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n") if Rails.env.development?

      # Specific error messages for better user experience
      error_message = case e.message
      when /指定された月にスタンプデータがありません/
                       "指定された月にスタンプデータがありません。まずはスタンプを押してから画像を生成してください。"
      when /Background image not found/
                       "テンプレート画像が見つかりません。管理者にお問い合わせください。"
      when /ImageMagick/
                       "画像処理エンジンでエラーが発生しました。しばらく時間をおいて再度お試しください。"
      else
                       "画像生成に失敗しました。しばらく時間をおいて再度お試しください。"
      end

      # Check if request expects JSON response
      if request.format.json? || request.xhr?
        render json: { status: "error", message: error_message }, status: :unprocessable_entity
      else
        redirect_to stamp_cards_path(year: @month.year, month: @month.month), alert: error_message
      end
    end
  end

  def download_image
    begin
      image_path = session[:stamp_card_image_path]

      # Validate session contains image path
      unless image_path
        Rails.logger.warn "Download attempted without image path in session for user #{current_user.id}"
        redirect_to stamp_cards_path, alert: "画像が生成されていません。まず画像を生成してからダウンロードしてください。"
        return
      end

      # Validate file exists and is readable
      unless File.exist?(image_path)
        Rails.logger.warn "Download attempted but file not found: #{image_path} for user #{current_user.id}"
        session.delete(:stamp_card_image_path)
        redirect_to stamp_cards_path, alert: "ダウンロードする画像が見つかりません。画像を再生成してください。"
        return
      end

      # Validate file size
      if File.size(image_path) == 0
        Rails.logger.warn "Download attempted but file is empty: #{image_path} for user #{current_user.id}"
        File.delete(image_path) rescue nil
        session.delete(:stamp_card_image_path)
        redirect_to stamp_cards_path, alert: "画像ファイルが破損しています。画像を再生成してください。"
        return
      end

      month = parse_month_params

      # Determine file type and extension from file path
      file_extension = File.extname(image_path)
      is_pdf = file_extension.downcase == ".pdf"

      filename = "stamp_card_#{month.year}_#{month.month}#{file_extension}"
      content_type = is_pdf ? "application/pdf" : "image/png"

      # Send file with proper error handling
      send_file image_path,
                filename: filename,
                type: content_type,
                disposition: "attachment"

      Rails.logger.info "Image download successful for user #{current_user.id}: #{filename}"

    rescue StandardError => e
      Rails.logger.error "Download failed for user #{current_user.id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n") if Rails.env.development?
      redirect_to stamp_cards_path, alert: "ダウンロード中にエラーが発生しました。しばらく時間をおいて再度お試しください。"
    ensure
      # Clean up temp file and session in ensure block
      if session[:stamp_card_image_path]
        begin
          File.delete(session[:stamp_card_image_path]) if File.exist?(session[:stamp_card_image_path])
        rescue StandardError => e
          Rails.logger.warn "Failed to clean up temp file: #{e.message}"
        end
        session.delete(:stamp_card_image_path)
      end
    end
  end

  private

  def ensure_json_format
    # This is called only for JSON format requests
    # We can add additional checks here if needed
  end

  def stamp_card_params
    params.require(:stamp_card).permit(:date, :stamped_at)
  end

  def parse_month_params
    if params[:year].present? && params[:month].present?
      begin
        year = params[:year].to_i
        month = params[:month].to_i

        # Validate reasonable year range
        if year < 2020 || year > Date.current.year + 1
          Rails.logger.warn "Invalid year parameter: #{year} for user #{current_user&.id}"
          return Date.current.beginning_of_month
        end

        # Validate month range
        if month < 1 || month > 12
          Rails.logger.warn "Invalid month parameter: #{month} for user #{current_user&.id}"
          return Date.current.beginning_of_month
        end

        Date.new(year, month, 1)
      rescue ArgumentError => e
        Rails.logger.warn "Date parsing error: #{e.message} for params #{params[:year]}/#{params[:month]}"
        Date.current.beginning_of_month
      end
    else
      Date.current.beginning_of_month
    end
  end

  def generate_calendar_data(month)
    month_start = month.beginning_of_month
    month_end = month.end_of_month

    # ユーザーのスタンプデータを取得
    stamps = current_user.stamp_cards.where(date: month_start..month_end)
                        .pluck(:date, :stamped_at).to_h

    calendar_data = []

    # カレンダーの開始日（日曜日から開始）
    start_date = month_start.beginning_of_week(:sunday)
    end_date = month_end.end_of_week(:sunday)

    (start_date..end_date).each_slice(7) do |week|
      week_data = week.map do |date|
        {
          date: date,
          date_day: date.day,  # Canvas用に日付の日のみ追加
          current_month: date.month == month.month,
          stamped: stamps.key?(date),
          stamped_time: stamps[date]&.strftime("%H:%M"),
          today: date == Date.current,
          can_stamp: date <= Date.current && !stamps.key?(date) && date.month == month.month
        }
      end
      calendar_data << week_data
    end

    calendar_data
  end

  def calculate_monthly_stats(month)
    month_start = month.beginning_of_month
    month_end = month.end_of_month

    stamps_in_month = current_user.stamp_cards.where(date: month_start..month_end)
    days_in_month = month_end.day
    days_passed = [ month_end, Date.current ].min.day

    {
      month: month,
      total_stamps: stamps_in_month.count,
      days_in_month: days_in_month,
      days_passed: days_passed,
      participation_rate: days_passed > 0 ? (stamps_in_month.count.to_f / days_passed * 100).round(1) : 0.0,
      can_stamp_today: current_user.can_stamp_today? && month.month == Date.current.month
    }
  end

  def calculate_user_stats
    {
      total_stamps: current_user.total_stamps,
      consecutive_days: current_user.consecutive_days,
      longest_streak: current_user.longest_streak,
      stamps_this_month: current_user.stamps_this_month,
      stamps_this_year: current_user.stamps_this_year,
      average_time: current_user.average_participation_time
    }
  end
end

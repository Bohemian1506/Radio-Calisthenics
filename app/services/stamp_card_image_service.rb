require "mini_magick"

class StampCardImageService
  attr_reader :user, :year, :month, :image

  def initialize(user:, year:, month:)
    @user = user
    @year = year
    @month = month
    @image = nil

    validate_parameters
  end

  def generate
    load_background_image
    draw_year_month
    draw_user_name

    @image
  rescue StandardError => e
    Rails.logger.error "StampCardImageService failed: #{e.message}"
    raise e
  end

  def save_to_file(path)
    generate unless @image
    @image.write(path)
  end

  private

  def validate_parameters
    raise ArgumentError, "User is required" unless @user
    raise ArgumentError, "Year must be a valid integer" unless @year.is_a?(Integer) && @year > 1900
    raise ArgumentError, "Month must be between 1 and 12" unless @month.is_a?(Integer) && (1..12).cover?(@month)
  end

  def load_background_image
    background_path = Rails.root.join("app", "assets", "images", "cards", "stamp_card.png")

    unless File.exist?(background_path)
      raise StandardError, "Background image not found: #{background_path}"
    end

    @image = MiniMagick::Image.open(background_path)
    # Safely get image dimensions without identify command if possible
    begin
      Rails.logger.info "Background image loaded: #{@image.width}x#{@image.height} pixels"
    rescue MiniMagick::Error => e
      Rails.logger.info "Background image loaded (dimensions unavailable: #{e.message})"
    end
  end

  def draw_year_month
    year_month_text = "#{@year}年#{@month}月"

    @image = @image.combine_options do |c|
      c.font "DejaVu-Sans"
      c.pointsize 36
      c.fill "black"
      c.gravity "northwest"
      c.annotate "+50,50", year_month_text
    end

    Rails.logger.info "Year/month text added: #{year_month_text}"
  end

  def draw_user_name
    return unless @user&.email

    # Display name logic: use name if available, otherwise email without domain
    display_name = if @user.respond_to?(:name) && @user.name.present?
                     @user.name
    else
                     @user.email.split("@").first
    end

    # Truncate if too long
    display_name = display_name.truncate(15, omission: "...")

    @image = @image.combine_options do |c|
      c.font "DejaVu-Sans"
      c.pointsize 24
      c.fill "black"
      c.gravity "northeast"
      c.annotate "+50,50", display_name
    end

    Rails.logger.info "User name added: #{display_name}"
  end

  def font_available?
    font_path = Rails.root.join("app", "assets", "fonts", "NotoSansCJK-Regular.ttc")
    File.exist?(font_path)
  end
end

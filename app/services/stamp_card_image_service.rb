require "mini_magick"

class StampCardImageService
  # Check ImageMagick availability
  def self.imagemagick_available?
    MiniMagick.cli_version
    true
  rescue StandardError
    false
  end

  attr_reader :user, :year, :month, :image

  # Image dimensions constants
  CALENDAR_WIDTH = 800
  CALENDAR_HEIGHT = 600
  CELL_WIDTH = 100
  CELL_HEIGHT = 80
  MARGIN_X = 50
  MARGIN_Y = 150
  STAMP_SIZE = 30

  def initialize(user:, year:, month:)
    @user = user
    @year = year
    @month = month
    @image = nil
    @stamps_data = nil

    validate_parameters
    load_stamps_data
  end

  def generate
    create_base_image
    draw_header
    draw_calendar_grid
    draw_dates
    draw_stamps
    draw_user_info

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

  def load_stamps_data
    month_start = Date.new(@year, @month, 1)
    month_end = month_start.end_of_month

    @stamps_data = @user.stamp_cards
                        .where(date: month_start..month_end)
                        .pluck(:date, :stamped_at)
                        .to_h

    Rails.logger.info "Loaded #{@stamps_data.count} stamps for #{@year}/#{@month}"
  end

  def create_base_image
    # Create a temporary file with a simple white canvas
    temp_file = Tempfile.new([ "calendar", ".png" ])
    temp_file.close

    # Use convert command to create white canvas
    MiniMagick::Tool::Convert.new do |c|
      c.size "#{CALENDAR_WIDTH}x#{CALENDAR_HEIGHT}"
      c.background "white"
      c << "xc:white"
      c << temp_file.path
    end

    @image = MiniMagick::Image.open(temp_file.path)

    Rails.logger.info "Base image created: #{CALENDAR_WIDTH}x#{CALENDAR_HEIGHT} pixels"
  end

  def draw_header
    year_month_text = "#{@year}年#{@month}月 ラジオ体操スタンプカード"

    @image = @image.combine_options do |c|
      c.font select_font
      c.pointsize 28
      c.fill "#2c3e50"
      c.gravity "north"
      c.annotate "+0,30", year_month_text
    end

    Rails.logger.info "Header added: #{year_month_text}"
  end

  def draw_calendar_grid
    # Draw weekday headers
    weekdays = %w[日 月 火 水 木 金 土]
    weekdays.each_with_index do |day, index|
      x = MARGIN_X + (index * CELL_WIDTH) + (CELL_WIDTH / 2)
      y = MARGIN_Y - 30

      @image = @image.combine_options do |c|
        c.font select_font
        c.pointsize 16
        c.fill "#34495e"
        c.gravity "northwest"
        c.annotate "+#{x - 10},#{y}", day
      end
    end

    # Draw grid lines
    7.times do |col|
      x = MARGIN_X + (col * CELL_WIDTH)
      @image = @image.combine_options do |c|
        c.stroke "#bdc3c7"
        c.strokewidth 1
        c.fill "none"
        c.draw "line #{x},#{MARGIN_Y} #{x},#{MARGIN_Y + (6 * CELL_HEIGHT)}"
      end
    end

    6.times do |row|
      y = MARGIN_Y + (row * CELL_HEIGHT)
      @image = @image.combine_options do |c|
        c.stroke "#bdc3c7"
        c.strokewidth 1
        c.fill "none"
        c.draw "line #{MARGIN_X},#{y} #{MARGIN_X + (7 * CELL_WIDTH)},#{y}"
      end
    end

    Rails.logger.info "Calendar grid drawn"
  end

  def draw_dates
    month_start = Date.new(@year, @month, 1)
    calendar_start = month_start.beginning_of_week(:sunday)

    6.times do |week|
      7.times do |day|
        date = calendar_start + (week * 7) + day
        row = week
        col = day

        x = MARGIN_X + (col * CELL_WIDTH) + 5
        y = MARGIN_Y + (row * CELL_HEIGHT) + 20

        # Date text color based on month and availability
        color = if date.month != @month
                  "#95a5a6"  # Gray for other months
        elsif date > Date.current
                  "#95a5a6"  # Gray for future dates
        else
                  "#2c3e50"  # Dark for current month
        end

        @image = @image.combine_options do |c|
          c.font select_font
          c.pointsize 14
          c.fill color
          c.gravity "northwest"
          c.annotate "+#{x},#{y}", date.day.to_s
        end
      end
    end

    Rails.logger.info "Calendar dates drawn"
  end

  def draw_stamps
    stamp_image_path = Rails.root.join("app", "assets", "images", "stamps", "finish_stamp.png")

    unless File.exist?(stamp_image_path)
      Rails.logger.warn "Stamp image not found: #{stamp_image_path}, using text stamps"
      draw_text_stamps
      return
    end

    month_start = Date.new(@year, @month, 1)
    calendar_start = month_start.beginning_of_week(:sunday)

    @stamps_data.each do |date, stamped_at|
      # Calculate grid position
      days_from_start = (date - calendar_start).to_i
      week = days_from_start / 7
      day = days_from_start % 7

      next if week >= 6  # Skip if beyond calendar grid

      x = MARGIN_X + (day * CELL_WIDTH) + (CELL_WIDTH / 2) - (STAMP_SIZE / 2)
      y = MARGIN_Y + (week * CELL_HEIGHT) + (CELL_HEIGHT / 2) - (STAMP_SIZE / 2) + 10

      # Composite stamp image
      stamp = MiniMagick::Image.open(stamp_image_path)
      stamp.resize "#{STAMP_SIZE}x#{STAMP_SIZE}"

      @image = @image.composite(stamp) do |c|
        c.geometry "+#{x}+#{y}"
      end
    end

    Rails.logger.info "#{@stamps_data.count} stamp images placed"
  end

  def draw_text_stamps
    month_start = Date.new(@year, @month, 1)
    calendar_start = month_start.beginning_of_week(:sunday)

    @stamps_data.each do |date, stamped_at|
      # Calculate grid position
      days_from_start = (date - calendar_start).to_i
      week = days_from_start / 7
      day = days_from_start % 7

      next if week >= 6  # Skip if beyond calendar grid

      x = MARGIN_X + (day * CELL_WIDTH) + (CELL_WIDTH / 2) - 10
      y = MARGIN_Y + (week * CELL_HEIGHT) + (CELL_HEIGHT / 2) + 10

      @image = @image.combine_options do |c|
        c.font select_font
        c.pointsize 20
        c.fill "#e74c3c"
        c.gravity "northwest"
        c.annotate "+#{x},#{y}", "★"
      end
    end

    Rails.logger.info "#{@stamps_data.count} text stamps placed"
  end

  def draw_user_info
    return unless @user&.email

    # Display name logic: use name if available, otherwise email without domain
    display_name = if @user.respond_to?(:name) && @user.name.present?
                     @user.name
    else
                     @user.email.split("@").first
    end

    # Truncate if too long
    display_name = display_name.truncate(15, omission: "...")

    # Draw user name in bottom right
    @image = @image.combine_options do |c|
      c.font select_font
      c.pointsize 16
      c.fill "#7f8c8d"
      c.gravity "southeast"
      c.annotate "+20,20", display_name
    end

    # Draw stats
    total_stamps = @stamps_data.count
    days_in_month = Date.new(@year, @month, -1).day
    participation_rate = days_in_month > 0 ? ((total_stamps.to_f / days_in_month) * 100).round(1) : 0

    stats_text = "#{total_stamps}/#{days_in_month}日 (#{participation_rate}%)"

    @image = @image.combine_options do |c|
      c.font select_font
      c.pointsize 14
      c.fill "#7f8c8d"
      c.gravity "southeast"
      c.annotate "+20,45", stats_text
    end

    Rails.logger.info "User info added: #{display_name}, #{stats_text}"
  end

  def font_available?
    font_path = Rails.root.join("app", "assets", "fonts", "NotoSansCJK-Regular.ttc")
    File.exist?(font_path)
  end

  def select_font
    # Try to use different fonts based on environment
    if ENV["CI"]
      # Use Liberation fonts on CI (installed via fonts-liberation package)
      "Liberation-Sans"
    elsif Rails.env.development? || Rails.env.test?
      # Use DejaVu fonts on Docker development
      "DejaVu-Sans"
    else
      # Production default
      "Helvetica"
    end
  end
end

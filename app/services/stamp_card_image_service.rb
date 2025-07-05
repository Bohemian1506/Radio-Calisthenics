require "mini_magick"
require "json"

class StampCardImageService
  # Check ImageMagick availability
  def self.imagemagick_available?
    MiniMagick.cli_version
    true
  rescue StandardError
    false
  end

  attr_reader :user, :year, :month, :image

  def initialize(user:, year:, month:, format: :png)
    @user = user
    @year = year
    @month = month
    @format = format
    @image = nil
    @stamps_data = nil
    @coordinates = load_coordinates

    validate_parameters
    load_stamps_data
  end

  def generate
    create_base_image
    draw_month_overlay
    draw_name_overlay
    draw_calendar_dates_overlay
    draw_stamps_overlay

    @image
  rescue StandardError => e
    Rails.logger.error "StampCardImageService failed: #{e.message}"
    raise e
  end

  def save_to_file(path)
    generate unless @image

    if @format == :pdf
      save_as_pdf(path)
    else
      @image.write(path)
    end
  end

  def save_as_pdf(path)
    begin
      # First save as high-quality PNG
      temp_png = Tempfile.new([ "calendar_temp", ".png" ])
      temp_png.close

      # Create high-resolution image for PDF
      high_res_image = @image.dup
      high_res_image.resize "1600x1200"  # Double resolution for print quality
      high_res_image.write(temp_png.path)

      # Convert PNG to PDF with security policy workaround
      MiniMagick::Tool::Convert.new do |c|
        c << temp_png.path
        c.density 300  # 300 DPI for print quality
        c.quality 95   # High quality
        c << path
      end

      temp_png.unlink
      Rails.logger.info "PDF saved: #{path} with 300 DPI print quality"
    rescue MiniMagick::Error => e
      # Fallback: Save as high-quality PNG instead
      Rails.logger.warn "PDF generation failed (#{e.message}), saving as high-quality PNG instead"
      high_quality_path = path.sub(/\.pdf$/i, "_print_quality.png")

      high_res_image = @image.dup
      high_res_image.resize "1600x1200"
      high_res_image.quality 95
      high_res_image.write(high_quality_path)

      # Copy to requested path for compatibility
      FileUtils.cp(high_quality_path, path.to_s.sub(/\.pdf$/i, ".png")) if path.to_s.end_with?(".pdf")

      Rails.logger.info "High-quality PNG saved instead: #{high_quality_path}"
    end
  end

  private

  def load_coordinates
    coordinates_file = Rails.root.join("config", "stamp_card_coordinates.json")
    JSON.parse(File.read(coordinates_file))
  rescue StandardError => e
    Rails.logger.error "Failed to load coordinates file: #{e.message}"
    raise "座標設定ファイルの読み込みに失敗しました"
  end

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
    template_path = Rails.root.join("app", "assets", "images", @coordinates["template"]["image_path"])

    unless File.exist?(template_path)
      raise "テンプレート画像が見つかりません: #{template_path}"
    end

    @image = MiniMagick::Image.open(template_path)

    # Ensure correct dimensions
    expected_width = @coordinates["template"]["width"]
    expected_height = @coordinates["template"]["height"]
    @image.resize "#{expected_width}x#{expected_height}!"

    Rails.logger.info "Template image loaded: #{template_path} (#{@image.width}x#{@image.height})"
  end

  def draw_month_overlay
    month_config = @coordinates["month_position"]
    month_text = "#{@month}"

    @image = @image.combine_options do |c|
      c.font select_font
      c.pointsize month_config["font_size"]
      c.fill month_config["font_color"]
      c.gravity "northwest"
      c.annotate "+#{month_config['x']},#{month_config['y']}", month_text
    end

    Rails.logger.info "Month overlay added: #{month_text} at (#{month_config['x']}, #{month_config['y']})"
  end

  def draw_name_overlay
    name_config = @coordinates["name_position"]
    return unless @user&.email

    # Display name logic: use name if available, otherwise email without domain
    display_name = if @user.respond_to?(:name) && @user.name.present?
                     @user.name
    else
                     @user.email.split("@").first
    end

    # Truncate if too long for template
    max_chars = (name_config["max_width"] || 200) / (name_config["font_size"] * 0.6)
    display_name = display_name.truncate(max_chars.to_i, omission: "...")

    @image = @image.combine_options do |c|
      c.font select_font
      c.pointsize name_config["font_size"]
      c.fill name_config["font_color"]
      c.gravity "northwest"
      c.annotate "+#{name_config['x']},#{name_config['y']}", display_name
    end

    Rails.logger.info "Name overlay added: #{display_name} at (#{name_config['x']}, #{name_config['y']})"
  end

  def draw_calendar_dates_overlay
    month_start = Date.new(@year, @month, 1)
    calendar_start = month_start.beginning_of_week(:sunday)
    
    date_config = @coordinates["date_positions"]
    cells = @coordinates["cells"]

    cells.each_with_index do |row, week|
      row.each_with_index do |cell, day|
        date = calendar_start + (week * 7) + day
        
        # Calculate position from cell coordinates
        x = cell["x"] + date_config["offset_x"]
        y = cell["y"] + date_config["offset_y"]

        # Date text color based on month
        color = if date.month != @month
                  date_config["inactive_color"]
        elsif date > Date.current
                  date_config["inactive_color"]
        else
                  date_config["font_color"]
        end

        @image = @image.combine_options do |c|
          c.font select_font
          c.pointsize date_config["font_size"]
          c.fill color
          c.gravity "northwest"
          c.annotate "+#{x},#{y}", date.day.to_s
        end
      end
    end

    Rails.logger.info "Calendar dates overlay completed"
  end

  def draw_stamps_overlay
    stamp_config = @coordinates["stamp_positions"]
    stamp_image_path = Rails.root.join("app", "assets", "images", stamp_config["image"])

    unless File.exist?(stamp_image_path)
      Rails.logger.warn "Stamp image not found: #{stamp_image_path}, using text stamps"
      draw_text_stamps_overlay
      return
    end

    month_start = Date.new(@year, @month, 1)
    calendar_start = month_start.beginning_of_week(:sunday)
    cells = @coordinates["cells"]

    @stamps_data.each do |date, stamped_at|
      # Calculate grid position
      days_from_start = (date - calendar_start).to_i
      week = days_from_start / 7
      day = days_from_start % 7

      next if week >= cells.length  # Skip if beyond calendar grid

      cell = cells[week][day]
      x = cell["x"] + stamp_config["offset_x"] - (stamp_config["size"] / 2)
      y = cell["y"] + stamp_config["offset_y"] - (stamp_config["size"] / 2)

      # Composite stamp image
      stamp = MiniMagick::Image.open(stamp_image_path)
      stamp.resize "#{stamp_config['size']}x#{stamp_config['size']}"

      @image = @image.composite(stamp) do |c|
        c.geometry "+#{x}+#{y}"
      end
    end

    Rails.logger.info "#{@stamps_data.count} stamp overlays placed"
  end

  def draw_text_stamps_overlay
    stamp_config = @coordinates["stamp_positions"]
    month_start = Date.new(@year, @month, 1)
    calendar_start = month_start.beginning_of_week(:sunday)
    cells = @coordinates["cells"]

    @stamps_data.each do |date, stamped_at|
      # Calculate grid position
      days_from_start = (date - calendar_start).to_i
      week = days_from_start / 7
      day = days_from_start % 7

      next if week >= cells.length  # Skip if beyond calendar grid

      cell = cells[week][day]
      x = cell["x"] + stamp_config["offset_x"] - 10
      y = cell["y"] + stamp_config["offset_y"]

      @image = @image.combine_options do |c|
        c.font select_font
        c.pointsize 20
        c.fill "#ff0000"
        c.gravity "northwest"
        c.annotate "+#{x},#{y}", "★"
      end
    end

    Rails.logger.info "#{@stamps_data.count} text stamp overlays placed"
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
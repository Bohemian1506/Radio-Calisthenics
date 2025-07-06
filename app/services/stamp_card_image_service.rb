class StampCardImageService
  def initialize(user, year, month, options = {})
    @user = user
    @year = year
    @month = month
    @theme = options[:theme] || 'default'
    @image_format = options[:image_format] || 'png'
  end

  def generate
    validate_parameters!
    
    # 簡単な実装として、既存の静的画像を返す
    image_path = Rails.root.join("app", "assets", "images", "radio_calisthenics_card.png")
    
    if File.exist?(image_path)
      # 一時ファイルとして保存
      temp_file = Tempfile.new(['stamp_card', '.png'])
      FileUtils.cp(image_path, temp_file.path)
      temp_file.close
      temp_file.path
    else
      raise StandardError, "画像ファイルが見つかりません"
    end
  end

  private

  def validate_parameters!
    raise ArgumentError, "無効な年です" if @year < 2020 || @year > Date.current.year + 1
    raise ArgumentError, "無効な月です" if @month < 1 || @month > 12
  end
end
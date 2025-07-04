require "mini_magick"

# Configure MiniMagick for Docker and CI environments
MiniMagick.configure do |config|
  config.timeout = 120 # Increase timeout for image processing
end

# Ensure PATH includes ImageMagick binaries
ENV["PATH"] = "/usr/bin:/usr/local/bin:#{ENV['PATH']}" unless ENV["PATH"].include?("/usr/bin")

# Log ImageMagick version for debugging
if Rails.env.test? || Rails.env.development?
  begin
    Rails.logger.info "ImageMagick version: #{MiniMagick.cli_version}"
  rescue StandardError => e
    Rails.logger.warn "ImageMagick not found: #{e.message}"
  end
end

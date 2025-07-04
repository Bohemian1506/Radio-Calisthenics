require "mini_magick"

# Configure MiniMagick for Docker environment
MiniMagick.configure do |config|
  config.timeout = 120 # Increase timeout for image processing
end

# Ensure PATH includes ImageMagick binaries
ENV["PATH"] = "/usr/bin:#{ENV['PATH']}" unless ENV["PATH"].include?("/usr/bin")

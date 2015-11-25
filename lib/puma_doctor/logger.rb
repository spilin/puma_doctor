require 'logger'

module PumaDoctor
  class Logger
    def initialize(options = {})
      @logger = ::Logger.new(options[:log_file])
      @logger.level = options[:log_level] || ::Logger::INFO
    end

    def info(text)
      @logger.info(text)
    end

    def warn(text)
      @logger.warn(text)
    end

    def log_start
      @logger.info "[Puma Doctor] Starting..."
    end

  end
end

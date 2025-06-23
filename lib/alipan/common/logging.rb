# frozen_string_literal: true

require 'logger'

module Alipan
	module Common
		module Logging
			
			MAX_NUM_LOG = 100
      ROTATE_SIZE = 10 * 1024 * 1024

			# level = Logger::DEBUG | Logger::INFO | Logger::ERROR | Logger::FATAL
      def self.set_log_level(level)
        Logging.logger.level = level
      end

      def self.set_log_file(file)
        @log_file = file
      end

      def logger
        Logging.logger
      end

			private

      def self.logger
        unless @logger
          # Environment parameter ALIPAN_SDK_LOG_PATH used to set output log to a file,do not output log if not set
          @log_file ||= ENV["ALIPAN_SDK_LOG_PATH"]
          @logger = Logger.new(
              @log_file, MAX_NUM_LOG, ROTATE_SIZE)
          @logger.level = get_env_log_level || Logger::INFO
        end
        @logger
      end

      def self.get_env_log_level
        return unless ENV["ALIPAN_SDK_LOG_LEVEL"]
        case ENV["ALIPAN_SDK_LOG_LEVEL"].upcase
        when "DEBUG"
          Logger::DEBUG
        when "WARN"
          Logger::WARN
        when "ERROR"
          Logger::ERROR
        when "FATAL"
          Logger::FATAL
        when "UNKNOWN"
          Logger::UNKNOWN
        end
      end
		end
	end
end

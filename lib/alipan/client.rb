# frozen_string_literal: true

module Alipan
	class Client
		
		def initialize(opts)
			fail ArgumentError, "Argument access_token must be provided" unless opts[:access_token]

			@config = Config.new(opts)
			@protocol = Protocol.new(@config)
		end

		def get_drive(opts = {})
			@protocol.get_drive
		end
	end
end

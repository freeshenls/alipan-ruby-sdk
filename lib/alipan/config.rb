# frozen_string_literal: true

module Alipan
	class Config < Alipan::Common::Struct

		attrs :access_token, :open_timeout, :read_timeout

		def initialize(opts = {})
			super(opts)

			@access_token = @access_token.strip if @access_token
		end
	end
end

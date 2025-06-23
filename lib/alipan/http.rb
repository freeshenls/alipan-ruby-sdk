# frozen_string_literal: true

require 'rest-client'

module Alipan
	class HTTP
		
		DEFAULT_CONTENT_TYPE = 'application/json'
		AUTH_HEADER = 'Authorization'
		OPEN_TIMEOUT = 10
		READ_TIMEOUT = 120

		include Common::Logging

		def initialize(config)
			@config = config
    end

		def get(resources = {}, http_options = {}, &block)
      do_request('GET', resources, http_options, &block)
    end

    def put(resources = {}, http_options = {}, &block)
      do_request('PUT', resources, http_options, &block)
    end

    def post(resources = {}, http_options = {}, &block)
      do_request('POST', resources, http_options, &block)
    end

    def delete(resources = {}, http_options = {}, &block)
      do_request('DELETE', resources, http_options, &block)
    end

    def head(resources = {}, http_options = {}, &block)
      do_request('HEAD', resources, http_options, &block)
    end

    def options(resources = {}, http_options = {}, &block)
      do_request('OPTIONS', resources, http_options, &block)
    end

    private

    def do_request(verb, resources = {}, http_options = {}, &block)
    	sub_res = resources[:sub_res]

      headers = http_options[:headers] || {}
      headers['Content-Type'] ||= DEFAULT_CONTENT_TYPE
      headers[AUTH_HEADER] = @config.access_token if @config.access_token

      logger.debug("Send HTTP request, verb: #{verb}, resources: " \
                    "#{resources}, http options: #{http_options}")

      block_response = ->(r) { handle_response(r, &block) } if block
      request = RestClient::Request.new(
        :method => verb,
        :url => "https://open.aliyundrive.com#{sub_res}",
        :headers => headers,
        :payload => http_options[:body],
        :block_response => block_response,
        :open_timeout => @config.open_timeout  || OPEN_TIMEOUT,
        :read_timeout => @config.read_timeout || READ_TIMEOUT
      )
      response = request.execute do |resp, &blk|
        if resp.code >= 300
          e = RuntimeError.new JSON.parse(resp.body)
          logger.error(e.to_s)
          raise e
        else
          resp.return!(&blk)
        end
      end

      logger.debug("Received HTTP response, code: #{response.code}, headers: " \
                    "#{response.headers}, body: #{response.body}")

      response
    end
	end
end

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

    def handle_response(r, &block)
      r.read_body { |chunk| yield chunk }
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

      headers = {}
      headers['Content-Type'] ||= DEFAULT_CONTENT_TYPE
      headers[AUTH_HEADER] = @config.access_token if @config.access_token

      logger.debug("Send HTTP request, verb: #{verb}, resources: " \
                    "#{resources}, http options: #{http_options}")

      block_response = ->(r) { handle_response(r, &block) } if block
      request = RestClient::Request.new(
        :method => verb,
        :url => "#{sub_res}".start_with?("/") ? "https://open.aliyundrive.com#{sub_res}" : "#{sub_res}",
        :headers => http_options[:headers] || headers,
        :payload => http_options[:body],
        :block_response => block_response,
        :open_timeout => @config.open_timeout  || OPEN_TIMEOUT,
        :read_timeout => @config.read_timeout || READ_TIMEOUT
      )
      begin
        response = request.execute 
      rescue RestClient::ExceptionWithResponse => e
        response = e.response
        response = RestClient::Response.create(response.body, Net::HTTPResponse.new('1.1', 200, 'OK'), request)
      end

      unless response.is_a?(RestClient::Response)
        response = RestClient::Response.create(nil, response, request)
        response.return!
      end

      logger.debug("Received HTTP response, code: #{response.code}, headers: " \
                    "#{response.headers}, body: #{response.body}")

      response
    end
	end
end

module RestClient
  module Payload
    class Base
      def headers
        ({'Content-Length' => size.to_s} if size) || {}
      end
    end
  end
end

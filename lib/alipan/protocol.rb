# frozen_string_literal: true

require 'json'

module Alipan
	class Protocol
		include Common::Logging

		def initialize(config)
			@config = config
			@http = HTTP.new(config)
		end

		def get_drive(opts = {})
			logger.info("Begin get drive, options: #{opts}")

			r = @http.post( {:sub_res => "/adrive/v1.0/user/getDriveInfo"}, {})
			body = JSON.parse(r.body)

			drive = Drive.new(
			{
				:user_id => body.fetch(:user_id.to_s),
				:name => body.fetch(:name.to_s),
				:avatar => body.fetch(:avatar.to_s),
				:default_drive_id => body.fetch(:default_drive_id.to_s),
				:resource_drive_id => body.fetch(:resource_drive_id.to_s),
				:backup_drive_id => body.fetch(:backup_drive_id.to_s),
				:folder_id => body.fetch(:folder_id.to_s)
			}, self)
			logger.info("Done get drive, drive: #{drive}")

			drive
		end

		def list_objects(drive_id, parent_file_id, opts = {})
			logger.info("Begin list objects, options: #{opts}")

			payload = {
				:drive_id => drive_id,
				:parent_file_id => parent_file_id,
				:marker => opts[:marker]
			}

			r = @http.post( {:sub_res => "/adrive/v1.0/openFile/list"}, {:body => payload.to_json})
			body = JSON.parse(r.body)

			objects = body[:items.to_s].map do |item|
				Object.new(item, self)
			end

			more = {
				:marker => body[:next_marker.to_s]
			}

			logger.debug("Done list object. objects: #{objects}, more: #{more}")

			[objects, more]
		end
	end
end

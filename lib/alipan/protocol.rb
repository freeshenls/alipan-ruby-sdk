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
			logger.debug("Begin list object, drive: #{drive_id}, options: #{opts}")

			payload = {
				:drive_id => drive_id,
				:parent_file_id => parent_file_id,
				:marker => opts[:marker]
			}

			r = @http.post( {:sub_res => "/adrive/v1.0/openFile/list"}, {:body => payload.to_json})
			body = JSON.parse(r.body)

			objects = body[:items.to_s].map do |item|
				Object.new(
					:drive_id => item.fetch(:drive_id.to_s),
					:file_id => item.fetch(:file_id.to_s),
					:parent_file_id => item.fetch(:parent_file_id.to_s),
					:name => item.fetch(:name.to_s),
					:size => item.fetch(:size.to_s),
					:file_extension => item.fetch(:file_extension.to_s),
					:content_hash => item.fetch(:content_hash.to_s),
					:category => item.fetch(:category.to_s),
					:type => item.fetch(:type.to_s),
					:thumbnail => item.fetch(:thumbnail.to_s),
					:url => item.fetch(:url.to_s),
					:created_at => item.fetch(:created_at.to_s),
					:updated_at => item.fetch(:updated_at.to_s),
					:video_media_metadata => item.fetch(:video_media_metadata.to_s),
					:video_preview_metadata => item.fetch(:video_preview_metadata.to_s))
			end || []

			more = {
				:marker => body[:next_marker.to_s]
			}

			logger.debug("Done list object. objects: #{objects}, more: #{more}")

			[objects, more]
		end

		def get_object(drive_id, object_name, opts = {}, &block)
			logger.debug("Begin get object, drive_id: #{drive_id}, "\
                     "object: #{object_name}")

			payload = {
				:drive_id => drive_id,
				:file_path => "#{object_name}".start_with?("/") ? "#{object_name}" : "/#{object_name}"
			}

			r = @http.post( {:sub_res => "/adrive/v1.0/openFile/get_by_path"}, {:body => payload.to_json})
			body = JSON.parse(r.body)

			obj = Object.new(
					:drive_id => body.fetch(:drive_id.to_s),
					:file_id => body.fetch(:file_id.to_s),
					:parent_file_id => body.fetch(:parent_file_id.to_s),
					:name => body.fetch(:name.to_s),
					:size => body.fetch(:size.to_s),
					:file_extension => body.fetch(:file_extension.to_s),
					:content_hash => body.fetch(:content_hash.to_s),
					:category => body.fetch(:category.to_s),
					:type => body.fetch(:type.to_s),
					:thumbnail => body.fetch(:thumbnail.to_s),
					:url => body.fetch(:url.to_s),
					:created_at => body.fetch(:created_at.to_s),
					:updated_at => body.fetch(:updated_at.to_s),
					:video_media_metadata => body.fetch(:video_media_metadata.to_s),
					:video_preview_metadata => body.fetch(:video_preview_metadata.to_s))

			if block_given?
				if obj.type == 'folder' || obj.file_id.nil?
					yield nil
				else
					payload = {
						:drive_id => drive_id,
						:file_id => obj.file_id
					}

					r = @http.post( {:sub_res => "/adrive/v1.0/openFile/getDownloadUrl"}, {:body => payload.to_json})
					body = JSON.parse(r.body)

					@http.get( {:sub_res => body.fetch(:url.to_s)}, {:headers => {}}, &block) 
				end
			end

			logger.debug("Done get object")

			obj
		end
	end
end

# frozen_string_literal: true

module Alipan
	class Object < Common::Struct
		
		attrs :drive_id, :file_id, :parent_file_id,
		:name, :size, :file_extension, :content_hash, 
		:category, :type, :thumbnail, :url, :created_at, 
		:updated_at, :play_cursor, :video_media_metadata, 
		:video_preview_metadata

		def initialize(opts = {}, protocol = nil)
			super(opts)
			@protocol = protocol
		end
	end
end

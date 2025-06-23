# frozen_string_literal: true

module Alipan
	class Drive < Common::Struct
		
		attrs :user_id, :name, :avatar, :default_drive_id, :resource_drive_id, :backup_drive_id, :folder_id

		def initialize(opts = {}, protocol = nil)
			super(opts)
			@protocol = protocol
		end

		def list_objects(opts = {})
			Iterator::Objects.new(@protocol, resource_drive_id, 'root', opts).to_enum
		end
	end
end

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

		def get_object(key, opts = {}, &block)
			obj = nil
			file = opts[:file]
			if file
				File.open(File.expand_path(file), 'wb') do |f|
					obj = @protocol.get_object(resource_drive_id, key, opts) do |chunk|
						f.write(chunk)
					end
				end
			elsif block
				obj = @protocol.get_object(resource_drive_id, key, opts, &block)
			else
				obj = @protocol.get_object(resource_drive_id, key, opts)
			end

			obj
		end

		def put_object(key, opts = {}, &block)
			file = opts[:file]

			if file
				@protocol.put_object(resource_drive_id, key, opts) do |sw|
					File.open(File.expand_path(file), 'rb') do |f|
						sw << f.read(Protocol::STREAM_CHUNK_SIZE) until f.eof?
					end
				end
			else
				@protocol.put_object(resource_drive_id, key, opts, &block)
			end
		end
		
	end
end

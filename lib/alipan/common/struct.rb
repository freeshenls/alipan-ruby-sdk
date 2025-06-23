# frozen_string_literal: true

module Alipan
	module Common
		class Struct
			
			def self.attrs(*s)
				define_method(:attrs) {s}
				attr_reader(*s)
			end

			def initialize(opts = {})
	      extra_keys = opts.keys - attrs
	      unless extra_keys.empty?
	        fail NameError,
	             "Unexpected extra keys: #{extra_keys.join(', ')}"
	      end

	      attrs.each do |attr|
	        instance_variable_set("@#{attr}", opts[attr])
	      end
	    end
		end
	end
end

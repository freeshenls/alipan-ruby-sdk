# frozen_string_literal: true

module Alipan
	class Adapter
		
		def initialize()
	    @producer = Fiber.new do 
	    	yield self if block_given?
	    	nil
	    end
	  end

		def read(length = nil, outbuf = nil)
	    chunk = @producer.resume
	    outbuf.replace(chunk) if outbuf && chunk
	    chunk
	  end

	  def write(chunk)
	  	Fiber.yield chunk.to_s.force_encoding(Encoding::ASCII_8BIT)
	  end

	  alias << write

	  def closed?
	  	false
	  end

	  def close
	  end
	end
end

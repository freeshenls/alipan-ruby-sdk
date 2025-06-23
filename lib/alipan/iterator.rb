# frozen_string_literal: true

module Alipan
  module Iterator
    class Base
      
      def initialize(protocol, opts = {})
        @protocol = protocol
        @results, @more = [], opts
      end

      def next
        loop do
          fetch_more if @results.empty?

          r = @results.shift
          break unless r

          yield r
        end
      end

      def to_enum
        self.enum_for(:next)
      end

      private
      def fetch_more
        return if @more[:truncated] == false
        fetch(@more)
      end
    end

    class Objects < Base
      def initialize(protocol, drive_id, parent_file_id, opts = {})
        super(protocol, opts)
        @drive_id = drive_id
        @parent_file_id = parent_file_id
      end

      def fetch(more)
        @results, cont = @protocol.list_objects(@drive_id, @parent_file_id, more)
        @more[:marker] = cont[:marker]
        @more[:truncated] = !cont[:marker].empty?
      end
    end
  end
end
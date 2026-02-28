# frozen_string_literal: true

module Vorbis
  class Comment
    include Clearable

    attr_reader :native

    def initialize
      @ptr = FFI::MemoryPointer.new(Native::VorbisComment.size)
      @native = Native::VorbisComment.new(@ptr)
      Native.vorbis_comment_init(@ptr)
      setup_clearable(Native.method(:vorbis_comment_clear))
    end

    def add_tag(tag, value)
      Native.vorbis_comment_add_tag(@ptr, tag, value)
    end

    def query(tag, index = 0)
      result = Native.vorbis_comment_query(@ptr, tag, index)
      result.null? ? nil : result.read_string
    end

    def query_count(tag)
      Native.vorbis_comment_query_count(@ptr, tag)
    end

    def vendor
      vendor_ptr = @native[:vendor]
      return nil if vendor_ptr.null?

      vendor_ptr.read_string
    end
  end
end

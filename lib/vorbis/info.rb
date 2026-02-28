# frozen_string_literal: true

module Vorbis
  class Info
    include Clearable

    attr_reader :native

    def initialize
      @ptr = FFI::MemoryPointer.new(Native::VorbisInfo.size)
      @native = Native::VorbisInfo.new(@ptr)
      Native.vorbis_info_init(@ptr)
      setup_clearable(Native.method(:vorbis_info_clear))
    end

    def encode_init_vbr(channels:, rate:, quality: 0.4)
      result = NativeEnc.vorbis_encode_init_vbr(@ptr, channels, rate, quality)
      raise InitError, "vorbis_encode_init_vbr failed with status #{result}" unless result == 0
    end

    def encode_init(channels:, rate:, max_bitrate: -1, nominal_bitrate:, min_bitrate: -1)
      result = NativeEnc.vorbis_encode_init(@ptr, channels, rate, max_bitrate, nominal_bitrate, min_bitrate)
      raise InitError, "vorbis_encode_init failed with status #{result}" unless result == 0
    end

    def channels
      @native[:channels]
    end

    def rate
      @native[:rate]
    end

    def bitrate_nominal
      @native[:bitrate_nominal]
    end
  end
end

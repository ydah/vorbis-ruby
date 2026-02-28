# frozen_string_literal: true

module Vorbis
  class Block
    include Clearable

    attr_reader :native

    def initialize(dsp_state)
      @dsp_state = dsp_state
      @ptr = FFI::MemoryPointer.new(Native::VorbisBlock.size)
      @native = Native::VorbisBlock.new(@ptr)
      result = Native.vorbis_block_init(dsp_state.native, @ptr)
      raise InitError, "vorbis_block_init failed with status #{result}" unless result == 0

      @pkt_ptr = FFI::MemoryPointer.new(Ogg::Native::OggPacket.size)
      setup_clearable(Native.method(:vorbis_block_clear))
    end

    def blockout
      result = Native.vorbis_analysis_blockout(@dsp_state.native, @ptr)
      result == 1
    end

    def analysis_and_addblock
      result = Native.vorbis_analysis(@ptr, nil)
      raise EncoderError, "vorbis_analysis failed with status #{result}" unless result == 0

      result = Native.vorbis_bitrate_addblock(@ptr)
      raise EncoderError, "vorbis_bitrate_addblock failed with status #{result}" unless result == 0
    end

    def flush_packet
      result = Native.vorbis_bitrate_flushpacket(@dsp_state.native, @pkt_ptr)
      return nil unless result == 1

      Native.packet_from_native(@pkt_ptr)
    end
  end
end

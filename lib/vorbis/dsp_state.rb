# frozen_string_literal: true

module Vorbis
  class DspState
    include Clearable

    attr_reader :native

    def initialize(info)
      @info = info
      @ptr = FFI::MemoryPointer.new(Native::VorbisDspState.size)
      @native = Native::VorbisDspState.new(@ptr)
      result = Native.vorbis_analysis_init(@ptr, info.native)
      raise InitError, "vorbis_analysis_init failed with status #{result}" unless result == 0

      setup_clearable(Native.method(:vorbis_dsp_clear))
    end

    def headerout(comment)
      op_ptr = FFI::MemoryPointer.new(Ogg::Native::OggPacket.size)
      op_comm_ptr = FFI::MemoryPointer.new(Ogg::Native::OggPacket.size)
      op_code_ptr = FFI::MemoryPointer.new(Ogg::Native::OggPacket.size)

      result = Native.vorbis_analysis_headerout(@ptr, comment.native, op_ptr, op_comm_ptr, op_code_ptr)
      raise EncoderError, "vorbis_analysis_headerout failed with status #{result}" unless result == 0

      [op_ptr, op_comm_ptr, op_code_ptr].map { |pkt_ptr| Native.packet_from_native(pkt_ptr) }
    end

    def analysis_buffer(samples)
      buffer_ptr = Native.vorbis_analysis_buffer(@ptr, samples)
      buffer_ptr.read_array_of_pointer(@info.channels)
    end

    def wrote(samples)
      result = Native.vorbis_analysis_wrote(@ptr, samples)
      raise EncoderError, "vorbis_analysis_wrote failed with status #{result}" unless result == 0
    end
  end
end

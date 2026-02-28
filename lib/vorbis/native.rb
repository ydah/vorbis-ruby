# frozen_string_literal: true

module Vorbis
  module Native
    extend FFI::Library
    ffi_lib ["libvorbis.so.0", "libvorbis.0.dylib", "libvorbis", "vorbis"]

    # --- Structs ---

    class VorbisInfo < FFI::Struct
      layout :version,          :int,
             :channels,         :int,
             :rate,             :long,
             :bitrate_upper,    :long,
             :bitrate_nominal,  :long,
             :bitrate_lower,    :long,
             :bitrate_window,   :long,
             :codec_setup,      :pointer
    end

    class VorbisComment < FFI::Struct
      layout :user_comments,    :pointer,
             :comment_lengths,  :pointer,
             :comments,         :int,
             :vendor,           :pointer
    end

    class VorbisDspState < FFI::Struct
      layout :analysisp,      :int,
             :vi,             :pointer,
             :pcm,            :pointer,
             :pcmret,         :pointer,
             :pcm_storage,    :int,
             :pcm_current,    :int,
             :pcm_returned,   :int,
             :preextrapolate, :int,
             :eofflag,        :int,
             :lW,             :long,
             :W,              :long,
             :nW,             :long,
             :centerW,        :long,
             :granulepos,     :int64,
             :sequence,       :int64,
             :glue_bits,      :int64,
             :time_bits,      :int64,
             :floor_bits,     :int64,
             :res_bits,       :int64,
             :backend_state,  :pointer
    end

    class VorbisBlock < FFI::Struct
      layout :pcm,              :pointer,
             # oggpack_buffer opb (inlined)
             :opb_endbyte,      :long,
             :opb_endbit,       :int,
             :opb_buffer,       :pointer,
             :opb_ptr,          :pointer,
             :opb_storage,      :long,
             # remaining fields
             :lW,               :long,
             :W,                :long,
             :nW,               :long,
             :pcmend,           :int,
             :mode,             :int,
             :eofflag,          :int,
             :granulepos,       :int64,
             :sequence,         :int64,
             :vd,               :pointer,
             :localstore,       :pointer,
             :localtop,         :long,
             :localalloc,       :long,
             :totaluse,         :long,
             :reap,             :pointer,
             :glue_bits,        :long,
             :time_bits,        :long,
             :floor_bits,       :long,
             :res_bits,         :long,
             :internal,         :pointer
    end

    # --- Info API ---

    attach_function :vorbis_info_init,      [:pointer],              :void
    attach_function :vorbis_info_clear,     [:pointer],              :void
    attach_function :vorbis_info_blocksize, [:pointer, :int],        :int

    # --- Comment API ---

    attach_function :vorbis_comment_init,       [:pointer],                         :void
    attach_function :vorbis_comment_clear,      [:pointer],                         :void
    attach_function :vorbis_comment_add,        [:pointer, :string],                :void
    attach_function :vorbis_comment_add_tag,    [:pointer, :string, :string],       :void
    attach_function :vorbis_comment_query,      [:pointer, :string, :int],          :pointer
    attach_function :vorbis_comment_query_count, [:pointer, :string],               :int

    # --- Synthesis/Analysis API ---

    attach_function :vorbis_analysis_init,      [:pointer, :pointer],                                    :int
    attach_function :vorbis_analysis_headerout,  [:pointer, :pointer, :pointer, :pointer, :pointer],     :int
    attach_function :vorbis_analysis_buffer,     [:pointer, :int],                                       :pointer
    attach_function :vorbis_analysis_wrote,      [:pointer, :int],                                       :int
    attach_function :vorbis_analysis_blockout,   [:pointer, :pointer],                                   :int
    attach_function :vorbis_analysis,            [:pointer, :pointer],                                   :int
    attach_function :vorbis_bitrate_addblock,    [:pointer],                                             :int
    attach_function :vorbis_bitrate_flushpacket, [:pointer, :pointer],                                   :int

    # --- Synthesis API ---

    attach_function :vorbis_synthesis_headerin,   [:pointer, :pointer, :pointer],    :int
    attach_function :vorbis_synthesis_init,       [:pointer, :pointer],              :int
    attach_function :vorbis_synthesis_restart,    [:pointer],                        :int
    attach_function :vorbis_synthesis,            [:pointer, :pointer],              :int
    attach_function :vorbis_synthesis_trackonly,  [:pointer, :pointer],              :int
    attach_function :vorbis_synthesis_blockin,    [:pointer, :pointer],              :int
    attach_function :vorbis_synthesis_pcmout,     [:pointer, :pointer],              :int
    attach_function :vorbis_synthesis_lapout,     [:pointer, :pointer],              :int
    attach_function :vorbis_synthesis_read,       [:pointer, :int],                  :int

    # --- Block API ---

    attach_function :vorbis_block_init,  [:pointer, :pointer], :int
    attach_function :vorbis_block_clear, [:pointer],           :int

    # --- DSP Cleanup ---

    attach_function :vorbis_dsp_clear, [:pointer], :void

    # --- Helpers ---

    def self.packet_from_native(pkt_ptr)
      native_pkt = Ogg::Native::OggPacket.new(pkt_ptr)
      data = native_pkt[:packet].read_bytes(native_pkt[:bytes])
      Ogg::Packet.new(
        data: data,
        bos: native_pkt[:b_o_s] != 0,
        eos: native_pkt[:e_o_s] != 0,
        granulepos: native_pkt[:granulepos],
        packetno: native_pkt[:packetno]
      )
    end
  end
end

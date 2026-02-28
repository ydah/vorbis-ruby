# frozen_string_literal: true

module Vorbis
  module NativeEnc
    extend FFI::Library
    ffi_lib ["libvorbisenc.so.2", "libvorbisenc.2.dylib", "libvorbisenc", "vorbisenc"]

    attach_function :vorbis_encode_init,           [:pointer, :long, :long, :long, :long, :long], :int
    attach_function :vorbis_encode_init_vbr,       [:pointer, :long, :long, :float],              :int
    attach_function :vorbis_encode_setup_init,     [:pointer],                                     :int
    attach_function :vorbis_encode_setup_managed,  [:pointer, :long, :long, :long, :long, :long], :int
    attach_function :vorbis_encode_setup_vbr,      [:pointer, :long, :long, :float],              :int
    attach_function :vorbis_encode_ctl,            [:pointer, :int, :pointer],                     :int
  end
end

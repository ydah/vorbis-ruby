# frozen_string_literal: true

require "ffi"
require "ogg"
require_relative "vorbis/version"
require_relative "vorbis/native"
require_relative "vorbis/native_enc"
require_relative "vorbis/clearable"
require_relative "vorbis/info"
require_relative "vorbis/comment"
require_relative "vorbis/dsp_state"
require_relative "vorbis/block"
require_relative "vorbis/encoder"

module Vorbis
  class Error < StandardError; end
  class EncoderError < Error; end
  class InitError < Error; end
end

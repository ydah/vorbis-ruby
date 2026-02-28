# frozen_string_literal: true

module Vorbis
  class Encoder
    def initialize(channels:, rate:, quality: 0.4, comments: {})
      @closed = false

      begin
        @info = Vorbis::Info.new
        @info.encode_init_vbr(channels: channels, rate: rate, quality: quality)

        @comment = Vorbis::Comment.new
        comments.each { |tag, value| @comment.add_tag(tag.to_s, value.to_s) }

        @dsp_state = Vorbis::DspState.new(@info)
        @block = Vorbis::Block.new(@dsp_state)
        @stream = Ogg::StreamState.new(rand(0xFFFFFF))
      rescue StandardError
        close
        raise
      end
    end

    def write_headers
      ensure_open!

      packets = @dsp_state.headerout(@comment)
      packets.each { |pkt| @stream.packetin(pkt) }

      while (page = @stream.flush)
        yield page.to_s
      end
    end

    def encode(samples)
      ensure_open!
      validate_samples!(samples)

      num_samples = samples.first.size
      return if num_samples.zero?

      buffer = @dsp_state.analysis_buffer(num_samples)

      samples.each_with_index do |channel_data, ch|
        buffer[ch].write_array_of_float(channel_data)
      end

      @dsp_state.wrote(num_samples)
      flush_blocks { |data| yield data }
    end

    def finish
      ensure_open!

      @dsp_state.wrote(0)
      flush_blocks { |data| yield data }
    end

    def close
      return if @closed

      @block&.clear
      @dsp_state&.clear
      @comment&.clear
      @info&.clear
      @stream&.clear
    ensure
      @closed = true
    end

    def closed?
      @closed
    end

    private

    def ensure_open!
      raise EncoderError, "encoder is closed" if @closed
    end

    def validate_samples!(samples)
      unless samples.is_a?(Array)
        raise ArgumentError, "samples must be an array of per-channel sample arrays"
      end

      expected_channels = @info.channels
      unless samples.size == expected_channels
        raise ArgumentError, "expected #{expected_channels} channels, got #{samples.size}"
      end

      num_samples = nil

      samples.each_with_index do |channel_data, channel_index|
        unless channel_data.is_a?(Array)
          raise ArgumentError, "channel #{channel_index} must be an array of numeric samples"
        end

        num_samples ||= channel_data.size
        unless channel_data.size == num_samples
          raise ArgumentError, "all channels must have the same number of samples"
        end
      end
    end

    def flush_blocks
      while @block.blockout
        @block.analysis_and_addblock

        while (packet = @block.flush_packet)
          @stream.packetin(packet)

          while (page = @stream.pageout)
            yield page.to_s
            break if page.eos?
          end
        end
      end
    end
  end
end

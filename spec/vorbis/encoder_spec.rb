# frozen_string_literal: true

RSpec.describe Vorbis::Encoder do
  let(:encoder) do
    described_class.new(
      channels: 2,
      rate: 44_100,
      quality: 0.4,
      comments: {"ARTIST" => "Test", "TITLE" => "Hello"}
    )
  end

  after do
    next unless instance_variable_defined?(:@encoder)

    @encoder.close unless @encoder.closed?
  end

  describe "#initialize" do
    it "creates a new Encoder instance" do
      expect(encoder).to be_a(described_class)
    end

    it "cleans up allocated resources when initialization fails" do
      info = instance_double(Vorbis::Info, encode_init_vbr: nil, clear: nil)
      comment = instance_double(Vorbis::Comment, clear: nil)

      allow(Vorbis::Info).to receive(:new).and_return(info)
      allow(Vorbis::Comment).to receive(:new).and_return(comment)
      allow(Vorbis::DspState).to receive(:new).and_raise(Vorbis::InitError, "boom")

      expect(info).to receive(:clear)
      expect(comment).to receive(:clear)

      expect do
        described_class.new(channels: 2, rate: 44_100)
      end.to raise_error(Vorbis::InitError, "boom")
    end
  end

  describe "#write_headers" do
    it "yields OGG page data" do
      pages = []
      encoder.write_headers { |data| pages << data }
      expect(pages).not_to be_empty
      expect(pages.first).to start_with("OggS")
    end

    it "raises when encoder is closed" do
      encoder.close

      expect do
        encoder.write_headers { |_| nil }
      end.to raise_error(Vorbis::EncoderError, "encoder is closed")
    end
  end

  describe "#encode" do
    it "raises when channel count does not match" do
      expect do
        encoder.encode([[0.0, 0.1]]) { |_| nil }
      end.to raise_error(ArgumentError, "expected 2 channels, got 1")
    end

    it "raises when channel sample sizes differ" do
      expect do
        encoder.encode([[0.0, 0.1], [0.0]]) { |_| nil }
      end.to raise_error(ArgumentError, "all channels must have the same number of samples")
    end

    it "raises when input is not an array" do
      expect do
        encoder.encode("invalid") { |_| nil }
      end.to raise_error(ArgumentError, "samples must be an array of per-channel sample arrays")
    end

    it "raises when encoder is closed" do
      encoder.close

      expect do
        encoder.encode([[0.0], [0.0]]) { |_| nil }
      end.to raise_error(Vorbis::EncoderError, "encoder is closed")
    end
  end

  describe "#finish" do
    it "raises when encoder is closed" do
      encoder.close

      expect do
        encoder.finish { |_| nil }
      end.to raise_error(Vorbis::EncoderError, "encoder is closed")
    end
  end

  describe "#close" do
    it "does not raise an error" do
      expect { encoder.close }.not_to raise_error
    end

    it "is idempotent" do
      encoder.close

      expect { encoder.close }.not_to raise_error
    end
  end
end

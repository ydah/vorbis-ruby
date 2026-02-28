# frozen_string_literal: true

RSpec.describe Vorbis::Info do
  subject(:info) { described_class.new }

  after { info.clear }

  describe "#initialize" do
    it "creates a new Info instance" do
      expect(info).to be_a(described_class)
    end

    it "has zero channels before encoding setup" do
      expect(info.channels).to eq(0)
    end
  end

  describe "#encode_init_vbr" do
    it "sets up VBR encoding" do
      info.encode_init_vbr(channels: 2, rate: 44_100, quality: 0.4)
      expect(info.channels).to eq(2)
      expect(info.rate).to eq(44_100)
    end

    it "raises InitError for invalid parameters" do
      expect {
        info.encode_init_vbr(channels: 0, rate: 0, quality: 0.4)
      }.to raise_error(Vorbis::InitError)
    end
  end

  describe "#encode_init" do
    it "sets up CBR encoding" do
      info.encode_init(channels: 2, rate: 44_100, nominal_bitrate: 128_000)
      expect(info.channels).to eq(2)
      expect(info.rate).to eq(44_100)
    end

    it "raises InitError for invalid parameters" do
      expect {
        info.encode_init(channels: 0, rate: 0, nominal_bitrate: 128_000)
      }.to raise_error(Vorbis::InitError)
    end
  end

  describe "#channels" do
    it "returns the number of channels" do
      info.encode_init_vbr(channels: 1, rate: 22_050, quality: 0.2)
      expect(info.channels).to eq(1)
    end
  end

  describe "#rate" do
    it "returns the sample rate" do
      info.encode_init_vbr(channels: 2, rate: 48_000, quality: 0.5)
      expect(info.rate).to eq(48_000)
    end
  end

  describe "#clear" do
    it "clears the info" do
      info.clear
      expect(info).to be_cleared
    end

    it "is idempotent" do
      info.clear
      expect { info.clear }.not_to raise_error
    end
  end
end

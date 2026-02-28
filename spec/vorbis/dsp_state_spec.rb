# frozen_string_literal: true

RSpec.describe Vorbis::DspState do
  let(:info) do
    info = Vorbis::Info.new
    info.encode_init_vbr(channels: 2, rate: 44_100, quality: 0.4)
    info
  end

  subject(:dsp_state) { described_class.new(info) }

  after do
    dsp_state.clear
    info.clear
  end

  describe "#initialize" do
    it "creates a new DspState instance" do
      expect(dsp_state).to be_a(described_class)
    end
  end

  describe "#headerout" do
    it "returns 3 packets" do
      comment = Vorbis::Comment.new
      packets = dsp_state.headerout(comment)
      expect(packets.size).to eq(3)
      packets.each do |pkt|
        expect(pkt).to be_a(Ogg::Packet)
        expect(pkt.bytes).to be > 0
      end
    ensure
      comment&.clear
    end
  end

  describe "#analysis_buffer" do
    it "returns an array of pointers for each channel" do
      buffer = dsp_state.analysis_buffer(1024)
      expect(buffer.size).to eq(2)
      buffer.each do |ptr|
        expect(ptr).to be_a(FFI::Pointer)
      end
    end
  end

  describe "#wrote" do
    it "does not raise for valid write" do
      dsp_state.analysis_buffer(1024)
      expect { dsp_state.wrote(1024) }.not_to raise_error
    end
  end

  describe "#clear" do
    it "clears the dsp state" do
      dsp_state.clear
      expect(dsp_state).to be_cleared
    end
  end
end

# frozen_string_literal: true

RSpec.describe Vorbis::Block do
  let(:info) do
    info = Vorbis::Info.new
    info.encode_init_vbr(channels: 2, rate: 44_100, quality: 0.4)
    info
  end

  let(:dsp_state) { Vorbis::DspState.new(info) }

  subject(:block) { described_class.new(dsp_state) }

  after do
    block.clear
    dsp_state.clear
    info.clear
  end

  describe "#initialize" do
    it "creates a new Block instance" do
      expect(block).to be_a(described_class)
    end
  end

  describe "#blockout" do
    it "returns false when no data has been written" do
      expect(block.blockout).to be false
    end
  end

  describe "#clear" do
    it "clears the block" do
      block.clear
      expect(block).to be_cleared
    end
  end
end

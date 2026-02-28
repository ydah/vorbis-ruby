# frozen_string_literal: true

RSpec.describe "Vorbis encoding integration" do
  it "encodes a sine wave to a valid OGG file" do
    output = +""

    encoder = Vorbis::Encoder.new(
      channels: 2,
      rate: 44_100,
      quality: 0.4,
      comments: {"ARTIST" => "Test", "TITLE" => "Sine Wave"}
    )

    encoder.write_headers { |data| output << data }

    # Generate 1 second of 440Hz sine wave
    sample_rate = 44_100
    frequency = 440.0
    num_samples = sample_rate
    chunk_size = 1024

    (0...num_samples).step(chunk_size) do |offset|
      count = [chunk_size, num_samples - offset].min
      samples = Array.new(count) do |i|
        Math.sin(2.0 * Math::PI * frequency * (offset + i) / sample_rate).to_f
      end
      encoder.encode([samples, samples]) { |data| output << data }
    end

    encoder.finish { |data| output << data }
    encoder.close

    # Verify the output starts with OGG magic bytes
    expect(output).to start_with("OggS")
    expect(output.bytesize).to be > 1000

    # Write to /tmp for manual verification
    # File.open("/tmp/test_output.ogg", "wb") { |f| f.write(output) }
    # Verify with: ffplay /tmp/test_output.ogg or ogg123 /tmp/test_output.ogg
  end
end

# vorbis-ruby

Ruby FFI bindings for libvorbis and libvorbisenc. Provides Vorbis audio codec encoding functionality.

## Installation

### System Requirements

libvorbis and libvorbisenc must be installed on your system.

**macOS:**

```bash
brew install libvorbis
```

**Debian / Ubuntu:**

```bash
sudo apt-get install libvorbis-dev
```

**Fedora / RHEL:**

```bash
sudo dnf install libvorbis-devel
```

### Gem Installation

Add to your Gemfile:

```ruby
gem "vorbis-ruby"
```

Or install directly:

```bash
gem install vorbis-ruby
```

## Usage

```ruby
require "vorbis"

File.open("output.ogg", "wb") do |f|
  encoder = Vorbis::Encoder.new(
    channels: 2,
    rate: 44100,
    quality: 0.4,
    comments: { "ARTIST" => "Test", "TITLE" => "Hello" }
  )

  encoder.write_headers { |data| f.write(data) }

  # PCM data as per-channel float arrays (-1.0 to 1.0)
  samples = [Array.new(1024, 0.0), Array.new(1024, 0.0)]
  encoder.encode(samples) { |data| f.write(data) }

  encoder.finish { |data| f.write(data) }
  encoder.close
end
```

## API Reference

### `Vorbis::Encoder`

High-level encoder that manages all Vorbis resources internally.

- `initialize(channels:, rate:, quality: 0.4, comments: {})` — Create encoder with VBR quality (-0.1 to 1.0)
- `write_headers { |data| }` — Yield OGG header pages
- `encode(samples) { |data| }` — Encode PCM samples (array of per-channel float arrays) and yield OGG pages
- `finish { |data| }` — Signal end-of-stream and yield remaining OGG pages
- `close` — Release all resources

### `Vorbis::Info`

Low-level wrapper for `vorbis_info`.

- `encode_init_vbr(channels:, rate:, quality:)` — Set up VBR encoding
- `encode_init(channels:, rate:, nominal_bitrate:, max_bitrate: -1, min_bitrate: -1)` — Set up CBR/ABR encoding
- `channels`, `rate`, `bitrate_nominal` — Accessors
- `clear` — Release resources

### `Vorbis::Comment`

Low-level wrapper for `vorbis_comment`.

- `add_tag(tag, value)` — Add a comment tag
- `query(tag, index = 0)` — Query a tag value
- `query_count(tag)` — Count tags with a given name
- `vendor` — Get the vendor string
- `clear` — Release resources

### `Vorbis::DspState`

Low-level wrapper for `vorbis_dsp_state`.

- `headerout(comment)` — Generate 3 header packets
- `analysis_buffer(samples)` — Get per-channel write buffers
- `wrote(samples)` — Notify samples written (0 for EOS)
- `clear` — Release resources

### `Vorbis::Block`

Low-level wrapper for `vorbis_block`.

- `blockout` — Extract a block from DSP state
- `analysis_and_addblock` — Analyze block and add to bitrate management
- `flush_packet` — Flush a packet from bitrate management
- `clear` — Release resources

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

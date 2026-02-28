# frozen_string_literal: true

require_relative "lib/vorbis/version"

Gem::Specification.new do |spec|
  spec.name = "vorbis-ruby"
  spec.version = Vorbis::VERSION
  spec.authors = ["Yudai Takada"]
  spec.email = ["t.yudai92@gmail.com"]

  spec.summary = "Ruby FFI bindings for libvorbis and libvorbisenc"
  spec.description = "A Ruby FFI binding library for libvorbis and libvorbisenc, providing Vorbis audio codec encoding functionality."
  spec.homepage = "https://github.com/ydah/vorbis-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ydah/vorbis-ruby"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .idea/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi", "~> 1.15"
  spec.add_dependency "ogg-ruby", "~> 0.1"
end

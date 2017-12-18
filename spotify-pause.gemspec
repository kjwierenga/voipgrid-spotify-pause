# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spotify/pause/version'

Gem::Specification.new do |spec|
  spec.name          = "spotify-pause"
  spec.version       = Spotify::Pause::VERSION
  spec.authors       = ["Klaas Jan Wierenga"]
  spec.email         = ["k.j.wierenga@gmail.com"]

  spec.summary       = %q{Pause Spotify on incoming call from Voipgrid.}
  spec.description   = %q{This program will pause your Spotify session when an incoming call from Voipgrid is received..}
  spec.homepage      = "https://github.com/kjwierenga/spotify-pause"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = '' # E.g. set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "sinatra", "~> 1.4.6"
  spec.add_dependency "faye-websocket", "~> 0.10.7"
  spec.add_dependency "thin", "~> 1.7.2"
  spec.add_dependency "puma", "~> 3.11.0"
  spec.add_dependency "dotenv", "~> 2.2.1"
  # spec.add_dependency "redis", "~> 4.0.1"
end

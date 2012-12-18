Gem::Specification.new do |gem|
  gem.name          = "webfinger"
  gem.version       = File.read("VERSION").delete("\n\r")
  gem.authors       = ["nov matake"]
  gem.email         = ["nov@matake.jp"]
  gem.description   = %q{Ruby WebFinger client library}
  gem.summary       = %q{Ruby WebFinger client library, following IETF WebFinger WG spec updates.}
  gem.homepage      = "https://github.com/nov/webfinger"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency "httpclient", ">= 2.2.0.2"
  gem.add_runtime_dependency "multi_json"
  gem.add_runtime_dependency "activesupport", ">= 3"
  gem.add_development_dependency "rspec", ">= 2"
  gem.add_development_dependency "cover_me", ">= 1.2.0"
  gem.add_development_dependency "webmock", ">= 1.6.2"
end

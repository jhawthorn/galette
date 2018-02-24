# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "galette"
  spec.version       = "0.1.0"
  spec.authors       = ["John Hawthorn"]
  spec.email         = ["john.hawthorn@gmail.com"]

  spec.summary       = %q{A dependency resolver}
  spec.description   = %q{A dependency resolver, intended to resolve compatible gem versions quickly}
  spec.homepage      = "https://github.com/jhawthorn/galette"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end

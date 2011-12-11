# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "deferred_enum/version"

Gem::Specification.new do |s|
  s.name        = "deferred_enum"
  s.version     = DeferredEnum::VERSION
  s.authors     = ["Alexey Mikhaylov"]
  s.email       = ["amikhailov83@gmail.com"]
  s.homepage    = "https://github.com/take-five/deferred_enum"
  s.summary     = %q{Introduces lazy computations to Enumerable}
  s.description = File.read(File.expand_path('../README.rdoc', __FILE__))
  s.date        = Time.now.strftime('%Y-%m-%d')

  s.rubyforge_project = "deferred_enum"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end

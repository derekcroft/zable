# Provide a simple gemspec so you can easily use your engine
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "zable"
  s.summary = "HTML tables"
  s.description = "HTML searching, sorting and pagination made dead simple"
  s.files = Dir["lib/**/*", "app/**/*", "public/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.version = "0.1.0"
  s.authors = ["Derek Croft","Joe Kurleto"]

  s.add_runtime_dependency 'will_paginate'
end

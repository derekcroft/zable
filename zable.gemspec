# Provide a simple gemspec so you can easily use your engine
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "zable"
  s.summary = "HTML tables"
  s.description = "HTML searching, sorting and pagination made dead simple"
  s.files = Dir["lib/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.version = "0.0.1"

  s.add_runtime_dependency 'will_paginate'
end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "houston/scheduler/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "houston-scheduler"
  spec.version     = Houston::Scheduler::VERSION
  spec.authors     = ["Bob Lail"]
  spec.email       = ["bob.lailfamily@gmail.com"]

  spec.summary     = "A module for Houston that projects schedules for work based on information about tasks' effort and payoff."
  spec.description = "Given effort and value of to-do list items, Houston::Scheduler employs different strategies for sequencing work. Then it projects a schedule based on your Work-in-Progress constraints"
  spec.homepage    = "https://github.com/houston/houston-scheduler"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.test_files = Dir["test/**/*"]

  spec.add_dependency "houston-core", ">= 0.7.0.beta2"

  spec.add_development_dependency "bundler", "~> 1.11.2"
  spec.add_development_dependency "rake", "~> 11.2"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "konacha"
  spec.add_development_dependency "poltergeist"
end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "houston/scheduler/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "houston-scheduler"
  s.version     = Houston::Scheduler::VERSION
  s.authors     = ["Bob Lail"]
  s.email       = ["bob.lailfamily@gmail.com"]
  s.homepage    = "https://github.com/houstonmc/houston-scheduler"
  s.summary     = "A module for Houston that projects schedules for work based on information about tasks' effort and payoff."
  s.description = "Given effort and value of to-do list items, Houston::Scheduler employs different strategies for sequencing work. Then it projects a schedule based on your Work-in-Progress constraints"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.9"
  s.add_dependency "sass-rails", "~> 3.2.3"
  s.add_dependency "coffee-rails", "~> 3.2.1"
  s.add_dependency "handlebars_assets"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end

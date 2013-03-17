#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end


task 'load_app' do
  # load_app is defined and invoked in engine.rake, below
  # we have to sneak in our additions so konacha is loaded.
  
  require 'action_controller/railtie'
  require 'konacha'
  load 'tasks/konacha.rake'
  
  module Konacha
    def self.spec_root
      Houston::Scheduler::Engine.config.root + config.spec_dir
    end
  end
  
  class Konacha::Engine
    initializer "konacha.engine.environment", after: "konacha.environment" do
      # Rails.application is the dummy app in test/dummy
      Rails.application.config.assets.paths << Houston::Scheduler::Engine.config.root + Konacha.config.spec_dir
    end
  end
  
  require 'capybara/poltergeist'
  Konacha.configure do |config|
    config.driver = :poltergeist
  end if defined?(Konacha)
  
end


APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'


Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end


task :default => :test

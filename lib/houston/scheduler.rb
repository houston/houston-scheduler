require "houston/scheduler/engine"
require "houston/scheduler/configuration"

module Houston
  module Scheduler
    extend self
    
    attr_reader :config
    
  end
  
  Scheduler.instance_variable_set :@config, Scheduler::Configuration.new
end

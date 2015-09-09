require "houston/scheduler/engine"
require "houston/scheduler/configuration"

module Houston
  module Scheduler
    extend self

    def config(&block)
      @configuration ||= Scheduler::Configuration.new
      @configuration.instance_eval(&block) if block_given?
      @configuration
    end

  end
end

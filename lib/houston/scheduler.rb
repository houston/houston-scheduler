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



  Houston.add_project_feature :scheduler do
    name "Scheduler"
    path { |project| Houston::Scheduler::Engine.routes.url_helpers.project_path(project) }
  end

end

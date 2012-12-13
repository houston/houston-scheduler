module Houston
  module Scheduler
    class SchedulerController < ApplicationController
      layout "houston/scheduler/application"
      
      def index
        @projects = Project.all
      end
      
    end
  end
end

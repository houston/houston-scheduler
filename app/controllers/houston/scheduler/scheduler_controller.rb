module Houston
  module Scheduler
    class SchedulerController < ApplicationController
      include Unfuddle::NeqHelper
      layout "houston/scheduler/application"
      
      
      def index
        @projects = Project.all
      end
      
      
      def project
        @project = Project.find_by_slug!(params[:slug])
        @tickets = @project.find_tickets(
          :status => neq(:closed),
          :resolution => 0,
          :severity => neq("0 Suggestion"))
      end
      
      
    end
  end
end

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
        if @project.has_ticket_tracking?
          @tickets = @project.find_tickets(status: neq(:closed), resolution: 0)
        else
          render template: "houston/scheduler/scheduler/no_ticket_tracking"
        end
      end
      
      
    end
  end
end

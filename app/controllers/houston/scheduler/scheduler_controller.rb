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
        velocity = Setting["Velocity"].to_i
        quota = ProjectQuota.where(project_id: @project.id).order(:week).where(["week <= ?", Date.today]).first
        value = quota ? quota.value : 0
        @velocity = (velocity * (value / 100.0)).round(1)
        
        if @project.has_ticket_tracker?
          @tickets = @project.find_tickets(status: neq(:closed), resolution: 0)
        else
          render template: "houston/scheduler/scheduler/no_ticket_tracker"
        end
      end
      
      
    end
  end
end

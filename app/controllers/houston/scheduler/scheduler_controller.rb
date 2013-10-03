module Houston
  module Scheduler
    class SchedulerController < ApplicationController
      layout "houston/scheduler/application"
      
      
      def index
        @projects = Project.all
      end
      
      
      def project
        @project = Project.find_by_slug!(params[:slug])
        @title = "#{@project.name}: Scheduler"
        
        velocity = Setting["Velocity"].to_i
        quota = ProjectQuota.where(project_id: @project.id).order(:week).where(["week <= ?", Date.today]).first
        value = quota ? quota.value : 0
        @velocity = (velocity * (value / 100.0)).round(1)
        
        if @project.has_ticket_tracker?
          @tickets = @project.tickets.unclosed.includes(:ticket_prerequisites, :project)
          @milestones = @project.milestones.uncompleted
        else
          render template: "houston/scheduler/scheduler/no_ticket_tracker"
        end
      end
      
      
    end
  end
end

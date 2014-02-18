module Houston
  module Scheduler
    class MilestonesController < ApplicationController
      layout "houston/scheduler/application"
      
      
      def show
        @milestone = Milestone.unscoped.find(params[:id])
        @project = @milestone.project
        @tickets = @milestone.tickets
      end
      
      
      def create
        project = Project.find(params[:projectId])
        milestone = project.create_milestone!(params.pick(:name))
        if milestone.persisted?
          render json: milestone, status: :created
        else
          render json: milestone.errors, status: :unprocessable_entity
        end
      end
      
      
      def close
        @milestone = Milestone.unscoped.find(params[:id])
        @milestone.close!
        render json: {}
      end
      
      
    end
  end
end

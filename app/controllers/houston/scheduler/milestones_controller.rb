module Houston
  module Scheduler
    class MilestonesController < ApplicationController
      
      
      def create
        project = Project.find(params[:projectId])
        milestone = project.create_milestone!(params.pick(:name))
        if milestone.persisted?
          render json: milestone, status: :created
        else
          render json: milestone.errors, status: :unprocessable_entity
        end
      end
      
      
    end
  end
end

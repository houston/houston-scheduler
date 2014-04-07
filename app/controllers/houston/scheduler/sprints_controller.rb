module Houston
  module Scheduler
    class SprintsController < ApplicationController
      attr_reader :sprint
      
      layout "houston/scheduler/application"
      before_filter :authenticate_user!
      before_filter :find_sprint, only: [:update, :edit, :show]
      
      
      def create
        authorize! :create, Sprint
        sprint = Sprint.create!
        sprint.ticket_ids = params[:ticket_ids]
        render json: sprint, status: :created
      end
      
      
      def update
        authorize! :update, sprint
        sprint.ticket_ids = Array(params[:ticket_ids]) + sprint.tickets.resolved.pluck(:id)
        head :ok
      end
      
      
      def current
        @sprint = Sprint.current
        if sprint
          authorize! :read, sprint
          redirect_to sprint_path(sprint)
        else
          authorize! :create, Sprint
          redirect_to new_sprint_path
        end
      end
      
      
      def new
        authorize! :create, Sprint
        
        @sprint = Sprint.current
        redirect_to sprint_path(sprint) if sprint
      end
      
      
      def show
        authorize! :read, sprint
      end
      
      
      def edit
        authorize! :update, sprint
      end
      
      
    private
      
      def find_sprint
        @sprint = Sprint.find(params[:id])
      end
      
    end
  end
end

module Houston
  module Scheduler
    class TasksController < ApplicationController
      
      
      def update
        task = Task.find params[:id]
        project = task.project
        authorize! :estimate, project
        effort = params[:effort]
        effort = effort.to_d if effort
        effort = nil if effort && effort <= 0
        task.update_column :effort, effort
        render json: [], status: :ok
      end
      
      
      def create
        ticket = ::Ticket.find params[:id]
        task = ticket.tasks.build params.slice(:description, :effort)
        if task.save
          render json: present_tasks(ticket), status: :created
        else
          render json: {errors: task.errors.full_messages}, status: :unprocessable_entity
        end
      end
      
      
      def destroy
        task = Task.find params[:id]
        ticket = task.ticket
        if task.destroy
          render json: present_tasks(ticket), status: :created
        else
          render json: {errors: task.errors.full_messages}, status: :unprocessable_entity
        end
      end
      
      
    private
      
      def present_tasks(ticket)
        ticket.tasks.map { |task| task.ticket = ticket; {
          id: task.id,
          description: task.description,
          number: task.number,
          letter: task.letter,
          effort: task.effort } }
      end
      
    end
  end
end

module Houston
  module Scheduler
    class SprintsController < ApplicationController
      attr_reader :sprint
      
      layout "houston/scheduler/application"
      before_filter :authenticate_user!
      before_filter :find_sprint, only: [:show, :add_ticket, :remove_ticket]
      
      
      def current
        @sprint = Sprint.current || Sprint.create!
        show
      end
      
      
      def show
        authorize! :read, sprint
        @open_tickets = ::Ticket.joins(:project).includes(:project).unclosed
        @tickets = @sprint.tickets.includes(:checked_out_by)
      end
      
      
      def add_ticket
        authorize! :update, sprint
        ticket = ::Ticket.find(params[:ticket_id])
        ticket.update_column :sprint_id, sprint.id
        render json: Houston::Scheduler::SprintTicketPresenter.new(ticket).to_json
      end
      
      def remove_ticket
        authorize! :update, sprint
        ::Ticket.where(id: params[:ticket_id]).update_all(sprint_id: nil)
        head :ok
      end
      
      
    private
      
      def find_sprint
        @sprint = Sprint.find(params[:id])
      end
      
    end
  end
end

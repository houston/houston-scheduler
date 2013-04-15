module Houston
  module Scheduler
    class TicketsController < ApplicationController
      
      
      def update
        @ticket = Ticket.find(params[:id])
        @project = ticket.project
        
        if params.key?(:sequence)
          authorize! :prioritize, project
          set_ticket_position!(params[:sequence])
          render json: [], :status => :ok
          return
        end
        
        
        extended_attributes = @ticket.extended_attributes
        
        if params.key?(:estimatedEffort)
          authorize! :estimate, project
          extended_attributes["estimated_effort"] = params[:estimatedEffort]
        end
        
        if params.key?(:estimatedValue)
          authorize! :prioritize, project
          extended_attributes["estimated_value"] = params[:estimatedValue]
        end
        
        if params.key?(:unableToSetEstimatedEffort)
          authorize! :estimate, project
          extended_attributes["unable_to_set_estimated_effort"] = params[:unableToSetEstimatedEffort]
        end
        
        if params.key?(:unableToSetEstimatedValue)
          authorize! :prioritize, project
          extended_attributes["unable_to_set_estimated_value"] = params[:unableToSetEstimatedValue]
        end
        
        
        if ticket.update_attributes(extended_attributes: extended_attributes)
          render json: [], :status => :ok
        else
          render json: ticket.errors, :status => :unprocessable_entity
        end
      end
      
      
    private
      
      
      attr_reader :ticket, :project
      
      def set_ticket_position!(position)
        old_position = ticket.extended_attributes["sequence"]
        return true if old_position == (position && position.to_s)
        
        old_position = old_position.to_i
        new_position = position.to_i
        
        Ticket.transaction do
          if new_position.zero?               # was dragged out of the list
            decrement_position_of_subsequent_items!(old_position)
          elsif old_position.zero?            # was dragged into the list
            increment_position_of_subsequent_items!(new_position)
          elsif new_position > old_position   # was moved down
            decrement_position_of_intermediate_items!(old_position..new_position)
          else                                # was moved up
            increment_position_of_intermediate_items!(new_position..old_position)
          end
          
          ticket.update_attributes!(extended_attributes: ticket.extended_attributes.merge("sequence" => position))
        end
      end
      
      def decrement_position_of_subsequent_items!(from_position)
        bump_position_of_tickets! -1, project.tickets
          .where("(extended_attributes->'sequence') IS NOT NULL")
          .where("(extended_attributes->'sequence')::int >= #{from_position}")
      end
      
      def increment_position_of_subsequent_items!(from_position)
        bump_position_of_tickets! +1, project.tickets
          .where("(extended_attributes->'sequence') IS NOT NULL")
          .where("(extended_attributes->'sequence')::int >= #{from_position}")
      end
      
      def decrement_position_of_intermediate_items!(range)
        bump_position_of_tickets! -1, project.tickets
          .where("(extended_attributes->'sequence') IS NOT NULL")
          .where("(extended_attributes->'sequence')::int BETWEEN #{range.begin} AND #{range.end}")
      end
      
      def increment_position_of_intermediate_items!(range)
        bump_position_of_tickets! +1, project.tickets
          .where("(extended_attributes->'sequence') IS NOT NULL")
          .where("(extended_attributes->'sequence')::int BETWEEN #{range.begin} AND #{range.end}")
      end
      
      def bump_position_of_tickets!(bump_by, tickets)
        tickets
          .reorder("(extended_attributes->'sequence')::int") # sorted by sequence
          .update_all("extended_attributes = extended_attributes || ('sequence=>' || ((extended_attributes->'sequence')::int + #{bump_by}))::hstore")
      end
      
      
    end
  end
end

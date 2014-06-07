module Houston
  module Scheduler
    class TicketsController < ApplicationController
      
      
      def update
        @ticket = ::Ticket.find(params[:id])
        @project = ticket.project
        
        
        extended_attributes = @ticket.extended_attributes.dup
        
        params.keys.grep(/estimatedEffort\[\d+\]/).each do |key|
          authorize! :estimate, project
          extended_attributes[key.gsub(/estimatedEffort/, "estimated_effort")] = params[key]
        end
        
        if params.key?(:estimatedValue)
          authorize! :prioritize, project
          extended_attributes["estimated_value"] = params[:estimatedValue]
        end
        
        %w{seriousness likelihood clumsiness}.each do |key|
          if params.key?(key)
            authorize! :prioritize, project
            extended_attributes[key] = params[key]
          end
        end
        
        params.keys.grep(/estimatedValue\[\d+\]/).each do |key|
          authorize! :prioritize, project
          extended_attributes[key.gsub(/estimatedValue/, "estimated_value")] = params[key]
        end
        
        if params.key?(:unableToSetEstimatedEffort)
          authorize! :estimate, project
          extended_attributes["unable_to_set_estimated_effort"] = params[:unableToSetEstimatedEffort]
        end
        
        if params.key?(:unableToSetPriority)
          authorize! :prioritize, project
          extended_attributes["unable_to_set_priority"] = params[:unableToSetPriority]
        end
        
        if params.key?(:postponed)
          authorize! :prioritize, project
          extended_attributes["postponed"] = params[:postponed]
        end
        
        
        
        attributes = {extended_attributes: extended_attributes}
        
        if params.key?(:milestoneId)
          attributes[:milestone_id] = params[:milestoneId]
        end
        
        ticket.updated_by = current_user
        if ticket.update_attributes(attributes)
          render json: [], :status => :ok
        else
          render json: ticket.errors, :status => :unprocessable_entity
        end
      end
      
      
      def update_order
        @project = Project.find_by_slug!(params[:slug])
        ids = Array.wrap(params[:order]).map(&:to_i).reject(&:zero?)
        
        if ids.length > 0
          ::Ticket.transaction do
            project.tickets.where(::Ticket.arel_table[:id].not_in(ids))
              .update_all("extended_attributes = extended_attributes || 'sequence=>NULL'::hstore")
            
            ids.each_with_index do |id, i|
              ::Ticket.unscoped.where(id: id).update_all("extended_attributes = extended_attributes || 'sequence=>#{i+1}'::hstore")
            end
          end
        elsif params[:order] == "empty"
          project.tickets.update_all("extended_attributes = extended_attributes || 'sequence=>NULL'::hstore")
        end
        
        head :ok
      end
      
      
      attr_reader :ticket, :project
      
      
    end
  end
end

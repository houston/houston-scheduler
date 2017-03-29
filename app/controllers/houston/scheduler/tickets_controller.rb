module Houston
  module Scheduler
    class TicketsController < ApplicationController


      def update
        @ticket = ::Ticket.find(params[:id])
        @project = ticket.project


        props = {}

        params.keys.grep(/estimatedEffort\[\d+\]/).each do |key|
          authorize! :estimate, project
          props["scheduler.#{key}"] = params[key]
        end

        if params.key?(:estimatedValue)
          authorize! :prioritize, project
          props["scheduler.estimatedValue"] = params[:estimatedValue]
        end

        %w{seriousness likelihood clumsiness}.each do |key|
          if params.key?(key)
            authorize! :prioritize, project
            props["scheduler.#{key}"] = params[key]
          end
        end

        params.keys.grep(/estimatedValue\[\d+\]/).each do |key|
          authorize! :prioritize, project
          props["scheduler.#{key}"] = params[key]
        end

        if params.key?(:unableToSetEstimatedEffort)
          authorize! :estimate, project
          props["scheduler.unableToSetEstimatedEffort"] = params[:unableToSetEstimatedEffort]
        end

        if params.key?(:unableToSetPriority)
          authorize! :prioritize, project
          props["scheduler.unableToSetPriority"] = params[:unableToSetPriority]
        end

        if params.key?(:postponed)
          authorize! :prioritize, project
          props["scheduler.postponed"] = params[:postponed]
        end



        ticket.attributes = params.pick(:summary, :description)
        ticket.props.merge!(props)
        ticket.updated_by = current_user
        if ticket.save
          render json: [], :status => :ok
        else
          render json: ticket.errors, :status => :unprocessable_entity
        end
      end


      def update_order
        @project = ::Project.find_by_slug!(params[:slug])
        ids = Array.wrap(params[:order]).map(&:to_i).reject(&:zero?)

        if ids.length > 0
          ::Ticket.transaction do
            project.tickets.where(::Ticket.arel_table[:id].not_in(ids))
              .update_all("props = props || '{\"scheduler.sequence\": null}'::jsonb")

            ids.each_with_index do |id, i|
              ::Ticket.unscoped.where(id: id).update_all("props = props || '{\"scheduler.sequence\": #{i + 1}}'::jsonb")
            end
          end
        elsif params[:order] == "empty"
          project.tickets.update_all("props = props || '{\"scheduler.sequence\": null}'::jsonb")
        end

        head :ok
      end


      attr_reader :ticket, :project


    end
  end
end

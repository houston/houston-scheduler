module Houston
  module Scheduler
    class SprintsController < ApplicationController
      
      
      def create
        project = Project.find(params[:project_id])
        sprint = project.sprints.create!
        sprint.ticket_ids = params[:ticket_ids]
        render json: sprint, status: :created
      end
      
      
      def update
        sprint = Sprint.find(params[:id])
        sprint.ticket_ids = Array(params[:ticket_ids]) + sprint.tickets.resolved.pluck(:id)
        head :ok
      end
      
      
      def show
        sprint = Sprint.find(params[:id])
        render json: sprint.tickets.map { |t| {
          "id" => t.id,
          "number" => t.number,
          "ticketUrl" => t.ticket_tracker_ticket_url,
          "ticketSystem" => t.project.ticket_tracker_name,
          "type" => t.type.to_s.downcase.dasherize,
          "tags" => t.tags.map(&:to_h),
          "estimatedEffort" => t.extended_attributes["estimated_effort"],
          "sequence" => t.extended_attributes["sequence"],
          "summary" => t.summary,
          "description" => t.description,
          "firstReleaseAt" => t.first_release_at,
          "closedAt" => t.closed_at,
          "resolved" => !t.resolution.blank?,
          "checkedOutAt" => t.checked_out_at,
          "checkedOutBy" => present_user(t.checked_out_by)
        } }
      end
      
      
      def present_user(user)
        return nil unless user
        { id: user.id,
          email: user.email,
          name: user.name }
      end
      
      
    end
  end
end

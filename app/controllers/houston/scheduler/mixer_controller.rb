module Houston
  module Scheduler
    class MixerController < ApplicationController
      layout "houston/scheduler/application"
      before_filter :get_week_range
      load_and_authorize_resource :class => Houston::Scheduler::ProjectQuota
      
      
      def index
        @title = "Mixer"
        
        quotas = ProjectQuota.in_range(@weeks)
        
        @mixes = {}
        @weeks.step(7) do |week|
          @mixes[week] = quotas
            .find_all { |quota| quota.week == week }
            .each_with_object({}) { |quota, mix| mix[quota.project_id] = quota.value }
        end
        
        @readonly = !can?(:manage, Houston::Scheduler::ProjectQuota)
        
        @projects = Project.all.map { |project|
          { id: project.id,
            name: project.name,
            color: project.color,
            hex: "##{Houston.config.project_colors[project.color]}" } }
      end
      
      
      def update
        new_quotas = []
        params[:mixes].each do |week, mixes|
          week = Date.strptime(week, "%Y-%m-%d")
          mixes.each do |project_id, value|
            new_quotas << {
              week: week,
              project_id: project_id.to_i,
              value: value.to_i }
          end
        end
        
        ProjectQuota.transaction do
          ProjectQuota.in_range(@weeks).delete_all
          ProjectQuota.create(new_quotas)
        end
        
        head :ok
      end
      
      
    private
      
      def get_week_range
        @monday = Date.today.beginning_of_week
        @weeks = 3.weeks.ago(@monday)...12.weeks.since(@monday) # 15 weeks
      end
      
    end
  end
end

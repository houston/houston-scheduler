module Houston
  module Scheduler
    class MixerController < ApplicationController
      layout "houston/scheduler/application"
      
      
      def index
        @monday = Date.today.beginning_of_week
        @weeks = 3.weeks.ago(@monday)...12.weeks.since(@monday) # 15 weeks
        @mixes = {}
        @weeks.step(7) { |week| @mixes[week] = {} }
        @projects = Project.all.map { |project|
          { id: project.id,
            name: project.name,
            color: project.color,
            hex: "##{Houston.config.colors[project.color]}" } }
      end
      
      
    end
  end
end

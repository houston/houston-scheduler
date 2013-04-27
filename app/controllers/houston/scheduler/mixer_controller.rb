module Houston
  module Scheduler
    class MixerController < ApplicationController
      layout "houston/scheduler/application"
      
      
      def index
        @projects = Project.all.map do |project|
          { id: project.id,
            name: project.name,
            color: project.color,
            active: false,
            throttle: 0 }
        end
      end
      
      
    end
  end
end

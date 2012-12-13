module Houston
  module Scheduler
    class Engine < ::Rails::Engine
      isolate_namespace Houston::Scheduler
      
      # Enabling assets precompiling under rails 3.1
      if Rails.version >= '3.1'
        initializer :assets do |config|
          Rails.application.config.assets.precompile += %w( houston-scheduler/application.js houston-scheduler/application.css )
        end
      end
      
    end
  end
end

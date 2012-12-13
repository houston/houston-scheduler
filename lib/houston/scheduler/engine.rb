module Houston
  module Scheduler
    class Engine < ::Rails::Engine
      isolate_namespace Houston::Scheduler
    end
  end
end

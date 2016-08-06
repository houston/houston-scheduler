require "houston/scheduler/ticket"
require "houston/scheduler/project"

module Houston
  module Scheduler
    class Railtie < ::Rails::Railtie

      # The block you pass to this method will run for every request in
      # development mode, but only once in production.
      config.to_prepare do
        ::Ticket.send(:include, Houston::Scheduler::Ticket)
        ::Project.send(:include, Houston::Scheduler::Project)
      end

    end
  end
end

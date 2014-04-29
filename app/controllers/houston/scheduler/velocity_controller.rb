module Houston
  module Scheduler
    class VelocityController < ApplicationController
      layout "houston/scheduler/application"
      
      
      def index
        Houston.benchmark "[velocity] Load objects" do
          @tickets = ::Ticket.includes(:project, :commits).estimated.closed.with_commit_time
        end
      end
      
      
    end
  end
end

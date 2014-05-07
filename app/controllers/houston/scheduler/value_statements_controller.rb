module Houston
  module Scheduler
    class ValueStatementsController < ApplicationController
      
      def update
        project = Project.find(params[:id])
        if project.update_attributes(value_statements_attributes: params[:statements])
          head :ok
        else
          render text: project.errors.full_messages.to_sentence, status: :unprocessable_entity
        end
      end
      
    end
  end
end

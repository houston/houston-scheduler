module Houston
  module Scheduler
    class ValueStatementsController < ApplicationController
      
      def update
        project = Project.find(params[:id])
        update = UpdateValueStatements.new(params)
        update.updated_by = current_user
        if update.apply_to(project)
          render json: project.value_statements
        else
          render text: project.errors.full_messages.to_sentence, status: :unprocessable_entity
        end
      end
      
    end
  end
end

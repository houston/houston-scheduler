module Houston
  module Scheduler
    class UpdateValueStatements
      attr_reader :attributes
      
      def initialize(params)
        @attributes = params.fetch(:statements, [])
      end
      
      def apply_to(project)
        project.update_attributes(value_statements_attributes: attributes)
      end
      
    end
  end
end

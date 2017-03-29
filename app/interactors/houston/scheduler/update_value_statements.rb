module Houston
  module Scheduler
    class UpdateValueStatements
      attr_reader :attributes
      attr_accessor :updated_by

      def initialize(params)
        @attributes = params.fetch(:statements, {}).values
      end

      def apply_to(project)
        attributes.each do |attrs|
          if attrs["id"]
            statement = project.value_statements.find_by_id(attrs["id"])
            next unless statement
            if attrs["_destroy"] == "true"
              statement.destroy
            else
              statement.update_attributes(attrs)
            end
          else
            statement = project.value_statements.build(attrs)
            statement.save
          end
        end

        true
      end

    end
  end
end

require "active_support/concern"

module Houston
  module Scheduler
    module Ticket
      extend ActiveSupport::Concern
      
      included do
        default_scope reorder("NULLIF(extended_attributes->'sequence', '')::int")
      end
      
      def sequence
        extended_attributes["sequence"]
      end
      
      def sequence=(value)
        extended_attributes = extended_attributes.merge("sequence" => value)
      end
      
    end
  end
end

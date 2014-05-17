require "active_support/concern"

module Houston
  module Scheduler
    module Ticket
      extend ActiveSupport::Concern
      
      included do
        default_scope { reorder("NULLIF(tickets.extended_attributes->'sequence', '')::int") }
      end
      
      module ClassMethods
        
        def prioritized
          where("NULLIF(tickets.extended_attributes->'sequence', '')::int > 0")
        end
        
        def unprioritized
          where("NOT defined(tickets.extended_attributes, 'sequence') OR NULLIF(tickets.extended_attributes->'sequence', '')::int <= 0")
        end
        
        def able_to_prioritize
          where("NOT defined(tickets.extended_attributes, 'unable_to_set_priority') OR tickets.extended_attributes->'unable_to_set_priority' = ''")
        end
        
        def able_to_estimate
          where("NOT defined(tickets.extended_attributes, 'unable_to_set_estimated_effort') OR tickets.extended_attributes->'unable_to_set_estimated_effort' = ''")
        end
        
        def with_commit_time
          select { |ticket| ticket.commit_time > 0 }
        end
        
      end
      
      def sequence
        extended_attributes["sequence"]
      end
      
      def sequence=(value)
        extended_attributes["sequence"] = value
        extended_attributes_will_change!
      end
      
      def unable_to_prioritize?
        extended_attributes["unable_to_set_priority"] == "true"
      end
      
      def unable_to_estimate?
        extended_attributes["unable_to_set_estimated_effort"] == "true"
      end
      
      def unprioritized?
        sequence.blank?
      end
      
      def discussion_needed?
        unable_to_prioritize? or unable_to_estimate?
      end
      
    end
  end
end

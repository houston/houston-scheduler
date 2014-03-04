require "active_support/concern"

module Houston
  module Scheduler
    module Ticket
      extend ActiveSupport::Concern
      
      included do
        default_scope reorder("NULLIF(tickets.extended_attributes->'sequence', '')::int")
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
        
        def estimated
          where("NULLIF(tickets.extended_attributes->'estimated_effort', '')::numeric > 0")
        end
        
        def unestimated
          where("NOT defined(tickets.extended_attributes, 'estimated_effort') OR NULLIF(tickets.extended_attributes->'estimated_effort', '')::numeric <= 0")
        end
        
        def able_to_estimate
          where("NOT defined(tickets.extended_attributes, 'unable_to_set_estimated_effort') OR tickets.extended_attributes->'unable_to_set_estimated_effort' = ''")
        end
        
        def in_current_sprint
          joins(:project => :sprints)
            .where("tickets.sprint_id = sprints.id")
            .where("sprints.end_date >= current_date")
        end
        
      end
      
      def sequence
        extended_attributes["sequence"]
      end
      
      def sequence=(value)
        extended_attributes["sequence"] = value
        extended_attributes_will_change!
      end
      
      def effort
        extended_attributes["estimated_effort"]
      end
      
      def effort
        extended_attributes["estimated_effort"]
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
      
      def unestimated?
        [nil, "", "0"].member?(effort)
      end
      
      def discussion_needed?
        unable_to_prioritize? or unable_to_estimate?
      end
      
    end
  end
end

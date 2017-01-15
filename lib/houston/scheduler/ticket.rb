require "active_support/concern"

module Houston
  module Scheduler
    module Ticket
      extend ActiveSupport::Concern

      included do
        default_scope { reorder("NULLIF(tickets.props->'scheduler.sequence', to_jsonb(0))") }
      end

      module ClassMethods

        def prioritized
          where("tickets.props->'scheduler.sequence' is not null and (tickets.props->>'scheduler.sequence')::int > 0")
        end

        def unprioritized
          where("tickets.props->'scheduler.sequence' is null or (tickets.props->>'scheduler.sequence')::int <= 0")
        end

        def able_to_prioritize
          where("tickets.props->>'scheduler.unableToSetPriority' is null")
        end

        def able_to_estimate
          where("tickets.props->>'scheduler.unableToSetEstimatedEffort' is null")
        end

      end

      def sequence
        props["scheduler.sequence"]
      end

      def sequence=(value)
        props["scheduler.sequence"] = value
      end

      def unable_to_prioritize?
        props["scheduler.unableToSetPriority"]
      end

      def unable_to_estimate?
        props["scheduler.unableToSetEstimatedEffort"]
      end

      def unprioritized?
        sequence.blank?
      end

      def discussion_needed?
        unable_to_prioritize? or unable_to_estimate?
      end

      def able_to_estimate!
        return unless unable_to_estimate?
        update_prop! "scheduler.unableToSetEstimatedEffort", nil
      end

    end
  end
end

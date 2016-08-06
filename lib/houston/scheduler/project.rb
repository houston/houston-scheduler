require "active_support/concern"

module Houston
  module Scheduler
    module Project
      extend ActiveSupport::Concern

      included do
        has_many :value_statements, class_name: "Houston::Scheduler::ValueStatement", dependent: :destroy
        accepts_nested_attributes_for :value_statements, allow_destroy: true
      end

    end
  end
end

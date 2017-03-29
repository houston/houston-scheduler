module Houston
  module Scheduler
    class ValueStatement < ActiveRecord::Base
      self.table_name = "value_statements"

      belongs_to :project
      validates :project_id, :weight, presence: true
      validates :text, length: 2..36

    end
  end
end

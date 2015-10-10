module Houston
  module Scheduler
    class ProjectQuota < ActiveRecord::Base
      self.table_name = "project_quotas"

      belongs_to :project

      validates_presence_of :project, :week, :value
      validates_uniqueness_of :project_id, :scope => :week

      def self.in_range(range)
        where(week: range)
      end

    end
  end
end

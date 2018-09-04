# frozen_string_literal: true

module Crm
  module Academy
    class CourseSyncJob < SalesforceSyncJob

      SObjectName = "DOCEBO1_CO__c"
      SUngcIdName = "C_DC_COURSE_ID__c"
      SObjectPrefix = "a2w"

      def adapter_class
        ::Crm::Adapters::Academy::Course
      end
    end
  end
end

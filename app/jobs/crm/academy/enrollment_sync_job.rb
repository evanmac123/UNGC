# frozen_string_literal: true

module Crm
  module Academy
    class EnrollmentSyncJob < SalesforceSyncJob

      SObjectName = "DOCEBO2_CO__c"
      SUngcIdName = "Name"
      SObjectPrefix = "a2x"

      def adapter_class
        ::Crm::Adapters::Academy::Enrollment
      end

      def foreign_keys
        parent_record_id("C_DC_COURSE_ID__c", model.course, changed?(:academy_course_id))
        parent_record_id("Contact_Enrolled__c", model.contact, changed?(:contact_id))
      end

    end
  end
end

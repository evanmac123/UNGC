# frozen_string_literal: true

class Crm::Adapters::Academy::Enrollment < Crm::Adapters::Base

  def build_crm_payload
    column("C_DC_COURSE_ID__c", :academy_course_id) { |enrollemnt|
      enrollemnt.course.salesforce_id
    }

    column("Name", :academy_course_id) { |enrollemnt|
      enrollemnt.course&.name.truncate(80)
    }

    column("D_DC_COURSE_COMP__c", :completed_at)
    column("D_DC_COURSE_FA__c", :first_access)
    column("D_DC_COURSE_LA__c", :last_access)
    column("N_DC_TIME_IN_COURSE__c", :time_in_course)
    column("D_DC_ENROLL__c", :created_at)
    column("C_DC_COURSE_STATUS__c", :status)
    column("C_DC_TIMEZONESID__c", :timezone)
    column("C_SF_USER_ID__c", :user_id)
    column("C_SF_USER_TYPE__c", :user_type)
    column("N_DC_COMPLETION_PCT__c", :completion_percentage)
    column("N_DC_COURSE_SCORE__c", :score)
  end

end

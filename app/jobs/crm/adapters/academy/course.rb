# frozen_string_literal: true

class Crm::Adapters::Academy::Course < Crm::Adapters::Base

  def build_crm_payload
    column("C_DC_COURSE_ID__c", :id)
    column("Name", :name) { |c| c.name.truncate(80) }
    column("Course_Name__c", :name)
    column("C_DC_COURSE_CODE__c", :code)
    column("C_DC_COURSE_TYPE__c", :course_type)
    column("D_DELETE__c", :deleted_at)
    column("C_DC_COURSE_DESC__c", :description)
    column("C_DC_COURSE_LANG__c", :language)
    column("N_REVISION__c", :revision)
    column("D_UPDATE__c", :updated_at)
    column("D_CREATE__c", :created_at)
  end

end

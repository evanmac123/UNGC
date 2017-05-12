module DueDiligence
  module RiskAssessment
    class Edit < TestPage::Base
      def initialize(current_path)
        pattern = /(\d+)\/edit\z/
        @id = pattern.match(current_path)[1]
      end

      def path
        edit_admin_due_diligence_risk_assessment_path(@id)
      end

      def fill_in_world_check_allegations(with:)
        fill_in("risk_assessment_world_check_allegations", with: with)
      end
    end
  end
end


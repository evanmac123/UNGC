module DueDiligence
  module FinalDecision
    class Edit < TestPage::Base

      def initialize(current_path)
        @id = /(\d+)/.match(current_path)
      end

      def path
        edit_admin_due_diligence_final_decision_path(@id)
      end
    end
  end
end

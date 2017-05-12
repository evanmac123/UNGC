module DueDiligence
  module Legal
    class Edit < TestPage::Base

      def initialize(current_path)
        @id = /integrity_review\/(\d+)\/edit\z/.match(current_path)[1]
      end

      def path
        edit_admin_due_diligence_integrity_review_path(@id)
      end
    end
  end
end

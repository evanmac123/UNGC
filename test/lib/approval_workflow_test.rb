require 'test_helper'

class ApprovalWorkflowTest < ActiveSupport::TestCase

  context "non_rejected states" do
    should "be complete" do
      non_rejected =   [
          ApprovalWorkflow::STATE_PENDING_REVIEW,
          ApprovalWorkflow::STATE_IN_REVIEW,
          ApprovalWorkflow::STATE_NETWORK_REVIEW,
          ApprovalWorkflow::STATE_DELAY_REVIEW,
          ApprovalWorkflow::STATE_APPROVED
      ]

      assert_equal non_rejected, ApprovalWorkflow::NON_REJECTED_STATES, 'Non-rejected list has unexpected values'
    end
  end
end

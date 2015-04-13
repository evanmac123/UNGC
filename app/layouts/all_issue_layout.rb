class AllIssueLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'AllIssues'
  layout :all_issues

  has_meta_tags!
end

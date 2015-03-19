class IssueArea < Issue
  has_many :issues, class_name: 'Issue'
end

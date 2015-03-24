class Issue < ActiveRecord::Base
  belongs_to :issue_area, class_name: 'IssueArea'
end

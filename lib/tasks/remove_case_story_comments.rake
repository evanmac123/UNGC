namespace :db do
  desc "Remove comments associated with case stories"
  task :remove_case_story_comments => :environment do
    remove_case_story_comments
  end
end

private

def remove_case_story_comments
  Comment.where(commentable_type: 'CaseStory').destroy_all
end

class RemoveEmptyContributionDescriptions < ActiveRecord::Migration
  def up
    # part of an earlier migration left us with lots
    # of empty contribution descriptions. zap them.
    ContributionDescription.where(
      pledge:nil,
      pledge_continued:nil,
      payment:nil,
      contact:nil,
      additional:nil
    ).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

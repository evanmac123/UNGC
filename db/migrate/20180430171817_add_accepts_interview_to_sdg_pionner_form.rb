class AddAcceptsInterviewToSdgPionnerForm < ActiveRecord::Migration
  def change
    add_column :sdg_pioneer_submissions, :accepts_interview, :boolean
  end
end

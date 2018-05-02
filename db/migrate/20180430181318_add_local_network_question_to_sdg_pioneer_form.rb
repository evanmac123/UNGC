class AddLocalNetworkQuestionToSdgPioneerForm < ActiveRecord::Migration
  def change
    add_column :sdg_pioneer_submissions, :has_local_network, :boolean
    add_column :sdg_pioneer_submissions, :local_network_question, :text
  end
end

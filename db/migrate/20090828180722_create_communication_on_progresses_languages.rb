class CreateCommunicationOnProgressesLanguages < ActiveRecord::Migration
  def self.up
    create_table :communication_on_progresses_languages, :id => false do |t|
      t.integer :communication_on_progress_id
      t.integer :language_id
    end
  end

  def self.down
    drop_table :communication_on_progresses_languages
  end
end

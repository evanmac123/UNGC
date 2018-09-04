class CreateAcademyEnrollments < ActiveRecord::Migration
  def change
    create_table :academy_enrollments do |t|
      t.references :contact, index: true, foreign_key: true
      t.references :academy_course, index: true, foreign_key: true

      t.datetime :completed_at
      t.decimal :completion_percentage, precision: 14, scale: 4
      t.string :event_id, length: 64
      t.datetime :first_access
      t.datetime :last_access
      t.decimal :max_score, precision: 14, scale: 4
      t.string :path_completion, length: 10
      t.string :product_id, length: 64
      t.decimal :score, precision: 14, scale: 4
      t.string :so_id, length: 64
      t.string :status, lenth: 64
      t.string :task_id, length: 64
      t.bigint :time_in_course
      t.string :timezone, length: 64
      t.datetime :unenrolled_at
      t.string :user_id, length: 64
      t.string :user_type, length: 64

      t.timestamps null: false
    end
  end
end

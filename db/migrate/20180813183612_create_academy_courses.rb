class CreateAcademyCourses < ActiveRecord::Migration
  def change
    create_table :academy_courses do |t|
      t.string :code, length: 50, index: true
      t.string :name, length: 255
      t.string :course_type, length: 255
      t.datetime :deleted_at
      t.text :description, length: 255
      t.string :language, length: 100
      t.bigint :revision

      t.timestamps null: false
    end
  end
end

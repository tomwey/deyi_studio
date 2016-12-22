class CreateAppTasks < ActiveRecord::Migration
  def change
    create_table :app_tasks do |t|
      t.string :name, null: false
      t.decimal :price, precision: 6, scale: 2, null: false
      t.integer :put_in_count, default: 0, index: true
      t.integer :grab_count, default: 0
      t.datetime :start_time, null: false, index: true
      t.datetime :end_time, null: false, index: true
      t.references :app, index: true, foreign_key: true
      t.string :task_id
      t.decimal :special_price, precision: 6, scale: 2, default: 0
      t.string :keywords, null: false
      t.string :task_steps, null: false
      t.integer :sort, default: 0, index: true

      t.timestamps null: false
    end
    add_index :app_tasks, :task_id, unique: true
  end
end

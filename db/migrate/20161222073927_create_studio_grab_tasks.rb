class CreateStudioGrabTasks < ActiveRecord::Migration
  def change
    create_table :studio_grab_tasks do |t|
      t.string :ip, null: false
      t.references :studio, index: true, foreign_key: true
      t.references :app_task, index: true, foreign_key: true
      t.datetime :expired_at, null: false
      t.string :state, default: 'pending'
      t.decimal :reward, precision: 8, scale: 2, null: false

      t.timestamps null: false
    end
  end
end

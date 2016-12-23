class CreateEarningDetails < ActiveRecord::Migration
  def change
    create_table :earning_details do |t|
      t.references :app_task, index: true, foreign_key: true
      t.references :studio, index: true, foreign_key: true
      t.string :ip
      t.decimal :money, precision: 6, scale: 2, null: false

      t.timestamps null: false
    end
  end
end

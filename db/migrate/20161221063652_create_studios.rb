class CreateStudios < ActiveRecord::Migration
  def change
    create_table :studios do |t|
      t.string :studio_id, index: true, unique: true
      t.string :name, null: false
      t.string :intro
      t.string :address
      t.string :contact_name, null: false
      t.string :contact_number, null: false
      t.decimal :balance, default: 0, precision: 8, scale: 2
      t.decimal :earnings, default: 0, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end

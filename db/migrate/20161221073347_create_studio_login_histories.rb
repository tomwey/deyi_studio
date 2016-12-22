class CreateStudioLoginHistories < ActiveRecord::Migration
  def change
    create_table :studio_login_histories do |t|
      t.references :studio, index: true, foreign_key: true
      t.string :login_ip

      t.timestamps null: false
    end
  end
end

class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name,     null: false
      t.string :icon,     null: false
      t.string :app_size, null: false # 单位为MB，例如15.59MB
      t.string :appstore_url, null: false
      t.string :app_id # 如果是iOS平台，那么为苹果商店的apple id，否则自动生成一个唯一的id
      t.string :bundle_id, null: false
      t.string :url_scheme
      t.string :version, null: false
      t.string :os, default: 'iOS'
      t.string :devices, null: false
      t.string :app_price, default: '0.00'
      t.integer :rank

      t.timestamps null: false
    end
    add_index :apps, :app_id, unique: true
  end
end

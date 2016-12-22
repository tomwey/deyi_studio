ActiveAdmin.register App do

  menu parent: 'deyi'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :icon, :os, :devices, :version, :app_size, :bundle_id, :appstore_url, :app_id, :url_scheme, :app_price, :rank, :sort
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  selectable_column
  column('ID',:id) { |app| link_to app.id, cpanel_app_path(app) }
  column(:app_id, sortable: false) { |app| link_to app.app_id, cpanel_app_path(app) }
  column :name, sortable: false
  column :icon, sortable: false do |app|
    image_tag app.icon.url(:large)
  end
  column :version
  column :os, sortable: false
  column :devices, sortable: false
  column :bundle_id, sortable: false
  column(:appstore_url, sortable: false) { |app| link_to '去商店', app.appstore_url, target: '__blank' } 
  column :url_scheme, sortable: false do |app|
    app.url_scheme.present? ? app.url_scheme : '--'
  end
  column :app_size do |app|
    "#{app.app_size}MB"
  end
  column :app_price
  column :rank do |app|
    app.rank ? app.rank : '--'
  end
  
  actions

end

form html: { multipart: true } do |f|
  f.semantic_errors

  f.inputs '应用信息' do
    f.input :name
    f.input :icon, as: :file, hint: '图片格式为：jpg, jpeg, png, gif，尺寸为正方形'
    f.input :os, as: :select, collection: App.prefered_os, prompt: '-- 选择系统平台 --'
    f.input :devices, as: :select, collection: App.prefered_devices, prompt: '-- 选择设备平台 --'
    f.input :version, placeholder: '1.0.0_3.12'
    f.input :app_size, hint: '值为数值累些，单位为MB', placeholder: '15.9'
    f.input :bundle_id, hint: 'iOS应用Bundle ID或者Android应用包名', placeholder: 'com.test.abc'
    f.input :appstore_url, hint: '应用商店下载地址', placeholder: 'https://itunes.apple.com/app/us/id392019232?mt=8'
    f.input :app_id, hint: '苹果商店Apple ID, 如果不输入，系统会自动创建一个'
    f.input :url_scheme, hint: '苹果应用的URL Scheme，如果没有可以不填', placeholder: '可选'
    f.input :app_price, hint: '可能是应用的购买价格或者内付费价格', placeholder: '1.00'
    f.input :rank, hint: '应用在商店里的最新排名'
  end
  actions

end


end

# t.string :name,     null: false
# t.string :icon,     null: false
# t.string :app_size, null: false # 单位为MB，例如15.59MB
# t.string :appstore_url, null: false
# t.integer :app_id # 如果是iOS平台，那么为苹果商店的apple id，否则自动生成一个唯一的id
# t.string :bundle_id, null: false
# t.string :url_scheme
# t.string :version, null: false
# t.string :os, default: 'iOS'
# t.string :devices, null: false
# t.integer :rank

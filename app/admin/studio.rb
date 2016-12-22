ActiveAdmin.register Studio do

  menu parent: 'deyi'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :intro, :address, :contact_name, :contact_number
#

# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :name
    f.input :intro
    f.input :address
    f.input :contact_name
    f.input :contact_number
  end
  actions
end


end

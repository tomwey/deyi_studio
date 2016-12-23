# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Admin.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
SiteConfig.create!(key: 'qiniu_access_key', value: 'fLagxpsOWh8auXaF7WP5nGRR86PTyPW1L6xJ8wZx')
SiteConfig.create!(key: 'qiniu_secret_key', value: 'tjZhfVggncQUr0ki_Lh7Zm84445CEn8vtdyxcAdM')
SiteConfig.create!(key: 'qiniu_bucket', value: 'images-dev')
SiteConfig.create!(key: 'qiniu_bucket_domain', value: 'img-dev-qn.deyiwifi.com')
SiteConfig.create!(key: 'api_key', value: '4f8649737bc94fe68c29b1b138eba483')
SiteConfig.create!(key: 'access_key_expire_in', value: '600')
chef_gem 'ruby-libvirt' do
  compile_time true
  action :upgrade
end

chef_gem 'nokogiri' do
  compile_time true
  action :upgrade
end

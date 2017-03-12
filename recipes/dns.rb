execute "pkg_update" do
  command node['qemu']['pkg_update_command']
  action :run
end

package node['qemu']['pkg_names'] do
  action :upgrade
end

# include_recipe "qemu::install"

qemu_cloud_config 'dns' do
  path node['qemu']['cloud_config_path']
  hostname node['qemu']['cloud_config_hostname']
  config node['qemu']['cloud_config']
  action :create
  notifies :restart, "qemu_domain[dns]", :delayed
end

qemu_domain 'dns' do
  config node['qemu']['libvirt_dns']
  action :start
end

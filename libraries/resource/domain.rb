class ChefQemu
  class Resource
    class Domain < Chef::Resource
      resource_name :qemu_domain

      default_action :define
      allowed_actions :shutdown, :undefine, :define, :start, :autostart, :restart, :recreate

      property :xml, String
      property :domain, Object
      property :timeout, Integer, default: 60
    end
  end
end

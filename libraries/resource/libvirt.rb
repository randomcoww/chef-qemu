class ChefQemu
  class Resource
    class Libvirt < Chef::Resource
      include LibvirtConfig

      resource_name :qemu_libvirt

      default_action :define
      allowed_actions :shutdown, :undefine, :define, :start, :autostart, :recreate

      property :config, Hash
      property :xml, String, default: lazy { to_conf }
      property :domain, Object
      property :timeout, Integer, default: 60

      private

      def to_conf
        hash = config.to_hash.dup
        hash['domain']['name'] = name
        generate_config(hash)
      end
    end
  end
end

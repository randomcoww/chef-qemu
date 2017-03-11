class ChefQemu
  class Resource
    class Libvirt < Chef::Resource
      include ConfigGenerator

      resource_name :qemu_libvirt

      default_action :define
      allowed_actions :shutdown, :undefine, :define, :start, :autostart, :recreate

      property :xml, String, default: lazy { to_conf }
      property :config, Hash
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

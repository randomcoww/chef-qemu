class ChefQemu
  class Resource
    class Domain < Chef::Resource
      include ConfigGenerator

      resource_name :qemu_domain

      default_action :define
      allowed_actions :shutdown, :undefine, :define, :start, :autostart, :recreate

      property :config, Hash
      property :xml, String, desired_state: false,
                              default: lazy { to_conf }
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

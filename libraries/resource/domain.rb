class ChefQemu
  class Resource
    class Domain < Chef::Resource
      include LibvirtConfig

      resource_name :qemu_domain

      default_action :define
      allowed_actions :shutdown, :undefine, :define, :start, :restart, :recreate

      property :exists, [TrueClass, FalseClass]
      property :config, Hash
      property :xml, String, default: lazy { to_conf }
      property :domain, Object
      property :timeout, Integer, default: 60

      private

      def to_conf
        hash = config.to_hash.dup
        hash['domain']['name'] = name
        ConfigGenerator.generate_from_hash(hash)
      end
    end
  end
end

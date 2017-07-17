class ChefQemu
  class Resource
    class Network < Chef::Resource
      include LibvirtConfig

      resource_name :qemu_network

      default_action :define
      allowed_actions :define, :start

      property :exists, [TrueClass, FalseClass]
      property :config, Hash
      property :xml, String, default: lazy { to_conf }
      property :network, Object

      private

      def to_conf
        hash = config.to_hash.dup
        hash['network']['name'] = name
        ConfigGenerator.generate_from_hash(hash)
      end
    end
  end
end

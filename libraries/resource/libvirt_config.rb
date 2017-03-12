class ChefQemu
  class Resource
    class LibvirtConfig < Chef::Resource
      include LibvirtConfig

      resource_name :qemu_libvirt_config

      default_action :create
      allowed_actions :create, :delete

      property :exists, [TrueClass, FalseClass]
      property :config, Hash
      property :content, String, default: lazy { to_conf }
      property :path, String, default: lazy {
        ::File.join(Chef::Config[:file_cache_path], 'qemu_libvirt_config', name)
      }

      private

      def to_conf
        hash = config.to_hash.dup
        hash['domain']['name'] = name
        generate_config(hash)
      end
    end
  end
end

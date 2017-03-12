class ChefQemu
  class Resource
    class CloudConfig < Chef::Resource
      resource_name :qemu_cloud_config

      default_action :create
      allowed_actions :create, :delete

      property :exists, [TrueClass, FalseClass]
      property :hostname, String
      property :config, Hash
      property :path, String

      property :user_data_content, String, default: lazy {
        ['#cloud-config', config.to_hash.to_yaml].join($/)
      }

      property :meta_data_content, String, default: lazy {
        {
          'instance-id' => "iid-#{hostname}",
          'hostname' => hostname,
          'local-hostname' => hostname
        }.to_yaml
      }

      def user_data_path
        ::File.join(path, CloudInit::USER_DATA)
      end

      def meta_data_path
        ::File.join(path, CloudInit::META_DATA)
      end
    end
  end
end

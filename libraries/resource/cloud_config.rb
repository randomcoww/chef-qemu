class ChefQemu
  class Resource
    class CloudConfig < Chef::Resource
      resource_name :qemu_cloud_init

      default_action :create
      allowed_actions :create, :delete

      property :hostname, String
      property :path, String
      property :config, Hash

      property :user_data_path, String, default: lazy { ::File.join(path, CloudConfig::USER_DATA) }
      property :user_data_config, String, default: lazy { generate_user_data }
      property :meta_data_path, String, default: lazy { ::File.join(path, CloudConfig::META_DATA) }
      property :meta_data_config, String, default: lazy { generate_meta_data }

      private

      def generate_user_data
        ['#cloud-config', config.to_yml].join($/)
      end

      def generate_meta_data
        {
          'instance-id' => "iid-#{hostname}",
          'hostname' => hostname,
          'local-hostname' => hostname
        }.to_yaml
      end
    end
  end
end

class ChefQemu
  class Resource
    class CloudConfig < Chef::Resource
      resource_name :qemu_cloud_config

      default_action :create
      allowed_actions :create, :delete

      property :hostname, String
      property :path, String
      property :config, Hash

      property :user_data_path, String
      property :meta_data_path, String
      property :user_data_config, String, default: lazy { generate_user_data_config }
      property :meta_data_config, String, default: lazy { generate_meta_data_config }

      private

      def generate_user_data_config
        ['#cloud-config', config.to_yml].join($/)
      end

      def generate_meta_data_config
        {
          'instance-id' => "iid-#{hostname}",
          'hostname' => hostname,
          'local-hostname' => hostname
        }.to_yaml
      end
    end
  end
end

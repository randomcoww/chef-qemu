class ChefQemu
  class Resource
    class CloudConfig < Chef::Resource
      resource_name :qemu_cloud_config

      default_action :create
      allowed_actions :create, :delete

      property :hostname, String
      property :path, String
      property :config, Hash

      property :user_data_config, String, default: lazy { generate_user_data }
      property :meta_data_config, String, default: lazy { generate_meta_data }

      def user_data_path
        ::File.join(path, CloudInit::USER_DATA)
      end

      def meta_data_path
        ::File.join(path, CloudInit::META_DATA)
      end

      private

      def generate_user_data
        ['#cloud-config', config.to_hash.to_yaml].join($/)
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

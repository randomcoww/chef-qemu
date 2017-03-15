class ChefQemu
  class Resource
    class CloudConfig < Chef::Resource
      include CloudInit

      resource_name :qemu_cloud_config

      default_action :create
      allowed_actions :create, :delete

      property :exists, [TrueClass, FalseClass]
      property :hostname, String
      property :config, Hash
      property :path, String
      ## built in parsing for systemd hash
      ## format: file_path => systemd_unit as hash
      property :systemd_hash, Hash, default: {}

      property :user_data_content, String, default: lazy { to_conf }
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

      private

      def to_conf
        content = config.to_hash.dup
        content['write_files'] ||= []

        systemd_hash.each do |path, unit|
          content['write_files'] << {
            "path" => path,
            "content" => to_ini(unit)
          }
        end
        ['#cloud-config', content.to_yaml].join($/)
      end
    end
  end
end

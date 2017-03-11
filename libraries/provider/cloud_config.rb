class ChefQemu
  class Provider
    class CloudConfig < Chef::Provider
      provides :qemu_cloud_config, os: "linux"

      def load_current_resource
        @current_resource = ChefQemu::Resource::CloudConfig.new(new_resource.name)

        current_resource.user_data_path(::File.join(new_resource.path, 'user-data'))
        current_resource.meta_data_path(::File.join(new_resource.path, 'meta-data'))

        if ::File.exist?(current_resource.user_data_path)
          current_resource.user_data_config(::File.read(current_resource.user_data_path).chomp)
        end
        if ::File.exist?(current_resource.meta_data_path)
          current_resource.meta_data_config(::File.read(current_resource.meta_data_path).chomp)
        end

        current_resource
      end

      def action_create
        if current_resource.user_data_config != new_resource.user_data_config ||
          current_resource.meta_data_config != new_resource.meta_data_config

          converge_by("Create cloud-config: #{new_resource}") do
            meta_data.run_action(:create)
            user_data.run_action(:create)
          end
        end
      end

      def action_delete
        if !current_resource.user_data_config.nil? ||
          !current_resource.meta_data_config.nil?

          converge_by("Delete cloud-config: #{new_resource}") do
            meta_data.run_action(:delete)
            user_data.run_action(:delete)
          end
        end
      end

      private

      def user_data
        @user_data_config ||= Chef::Resource::File.new(current_resource.user_data_path, run_context).tap do |r|
          r.content current_resource.user_data_config
        end
      end

      def meta_data
        @meta_data_config ||= Chef::Resource::File.new(current_resource.meta_data_path, run_context).tap do |r|
          r.content current_resource.meta_data_config
        end
      end
    end
  end
end

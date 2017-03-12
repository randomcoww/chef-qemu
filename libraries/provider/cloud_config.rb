class ChefQemu
  class Provider
    class CloudConfig < Chef::Provider
      provides :qemu_cloud_config, os: "linux"

      def load_current_resource
        @current_resource = ChefQemu::Resource::CloudConfig.new(new_resource.name)

        current_resource.exists(
          ::File.exist?(new_resource.user_data_path) &&
          ::File.exist?(new_resource.meta_data_path)
        )

        if current_resource.exists
          current_resource.user_data_content(::File.read(new_resource.user_data_path))
          current_resource.meta_data_content(::File.read(new_resource.meta_data_path))
        else
          current_resource.user_data_content('')
          current_resource.meta_data_content('')
        end

        current_resource
      end

      def action_create
        if !current_resource.exists ||
          current_resource.user_data_content != new_resource.user_data_content ||
          current_resource.meta_data_content != new_resource.meta_data_content

          converge_by("Create cloud-config: #{new_resource}") do
            base_directory(:create_if_missing)
            meta_data.run_action(:create)
            user_data.run_action(:create)
          end
        end
      end

      def action_delete
        converge_by("Delete cloud-config: #{new_resource}") do
          meta_data.run_action(:delete)
          user_data.run_action(:delete)
        end if current_resource.exists
      end

      private

      def base_directory(action)
        Chef::Resource::Directory.new(new_resource.path, run_context).tap do |r|
          r.recursive true
        end.run_action(action)
      end

      def user_data
        @user_data ||= Chef::Resource::File.new(new_resource.user_data_path, run_context).tap do |r|
          r.content new_resource.user_data_content
        end
      end

      def meta_data
        @meta_data ||= Chef::Resource::File.new(new_resource.meta_data_path, run_context).tap do |r|
          r.content new_resource.meta_data_content
        end
      end
    end
  end
end

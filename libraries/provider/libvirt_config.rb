class ChefQemu
  class Provider
    class LibvirtConfig < Chef::Provider
      provides :qemu_libvirt_config, os: "linux"

      def load_current_resource
        @current_resource = ChefQemu::Resource::LibvirtConfig.new(new_resource.name)

        current_resource.exists(::File.exist?(new_resource.path))

        if current_resource.exists
          current_resource.content(::File.read(new_resource.path))
        else
          current_resource.content('')
        end

        current_resource
      end

      def action_create
        converge_by("Create nsd config: #{new_resource}") do
          base_directory(:create_if_missing)
          nsd_config.run_action(:create)
        end if !current_resource.exists || current_resource.content != new_resource.content
      end

      def action_delete
        converge_by("Delete nsd config: #{new_resource}") do
          nsd_config.run_action(:delete)
        end if current_resource.exists
      end

      private

      def base_directory(action)
        Chef::Resource::Directory.new(new_resource.path, run_context).tap do |r|
          r.recursive true
        end.run_action(action)
      end

      def libvirt_config
        @libvirt_config ||= Chef::Resource::File.new(new_resource.path, run_context).tap do |r|
          r.content new_resource.content
        end
      end
    end
  end
end

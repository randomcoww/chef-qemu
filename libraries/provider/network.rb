class ChefQemu
  class Provider
    class Network < Chef::Provider
      include LibvirtWrapper

      provides :qemu_network, os: "linux"

      def load_current_resource
        @current_resource = ChefQemu::Resource::Network.new(new_resource.name)

        begin
          current_resource.network(LibvirtNetwork.get_by_name(new_resource.name))
        rescue Libvirt::RetrieveError
          current_resource.network(nil)
        end
        current_resource.exists(current_resource.network && current_resource.network.exists?)

        current_resource
      end

      def action_define
        if !current_resource.exists
          converge_by("Define network: #{new_resource}") do
            LibvirtNetwork.get_or_define_from_xml(new_resource.xml)
          end
        end
      end

      def action_start
        network = LibvirtNetwork.get_or_define_from_xml(new_resource.xml)
        network.autostart(true)
        if !network.active?
          converge_by("Start network: #{new_resource}") do
            network.start
          end
        end
      end
    end
  end
end

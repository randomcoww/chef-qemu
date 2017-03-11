class ChefQemu
  class Provider
    class Libvirt < Chef::Provider
      include LibvirtHelper

      provides :qemu_libvirt, os: "linux"

      def load_current_resource
        @current_resource = ChefQemu::Resource::Libvirt.new(new_resource.name)
        current_resource.domain(Domain.get_current_from_xml(current_resource.xml))

        current_resource
      end

      def action_shutdown
        domain = current_resource.domain
        if !domain.nil? && domain.active?
          converge_by("Shutdown domain: #{new_resource}") do
            domain.set_autostart(false)
            domain.shutdown_or_destroy(new_resource.shutdown_timeout)
          end
        end
      end

      def action_recreate
        action_undefine
        action_start
        action_autostart
      end

      def action_undefine
        domain = current_resource.domain
        if !domain.nil?
          converge_by("Undefine domain: #{new_resource}") do
            domain.set_autostart(false)
            domain.shutdown_and_undefine(new_resource.shutdown_timeout)
          end
        end
      end

      def action_define
        if current_resource.domain.nil?
          converge_by("Define domain: #{new_resource}") do
            Domain.define_from_xml(new_resource.xml)
          end
        end
      end

      def action_start
        if current_resource.domain.nil? || !current_resource.domain.active?
          converge_by("Start domain: #{new_resource}") do
            domain = Domain.get_or_define_from_xml(new_resource.xml)
            domain.start(new_resource.timeout)
          end
        end
      end

      def action_autostart
        if current_resource.domain.nil? || !current_resource.domain.autostart?
          converge_by("Set domain autostart: #{new_resource}") do
            domain = Domain.get_or_define_from_xml(new_resource.xml)
            domain.set_autostart(true)
          end
        end
      end
    end
  end
end

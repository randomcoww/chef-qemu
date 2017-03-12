class ChefQemu
  class Provider
    class Domain < Chef::Provider
      include LibvirtWrapper

      provides :qemu_domain, os: "linux"

      def load_current_resource
        @current_resource = ChefQemu::Resource::Domain.new(new_resource.name)

        begin
          current_resource.domain(LibvirtDomain.get_by_name(new_resource.name))
        rescue Libvirt::RetrieveError
          current_resource.domain(nil)
        end
        current_resource.exists(current_resource.domain && current_resource.domain.exists?)

        current_resource
      end

      def action_recreate
        action_undefine
        action_start
      end

      def action_restart
        action_shutdown
        action_start
      end

      def action_shutdown
        if current_resource.exists
          domain = current_resource.domain
          domain.autostart(false)

          if domain.active?
            converge_by("Shutdown domain: #{new_resource}") do
              domain.shutdown_or_destroy(new_resource.timeout)
            end
          end
        end
      end

      def action_undefine
        if current_resource.exists
          domain = current_resource.domain
          domain.autostart(false)

          converge_by("Undefine domain: #{new_resource}") do
            if domain.active?
              domain.shutdown_or_destroy(new_resource.timeout)
            end
            # http://www.libvirt.org/html/libvirt-libvirt-domain.html#virDomainUndefineFlagsValues
            domain.undefine(7)
          end
        end
      end

      def action_define
        if !current_resource.exists
          converge_by("Define domain: #{new_resource}") do
            LibvirtDomain.get_or_define_from_xml(new_resource.xml)
          end
        end
      end

      def action_start
        domain = LibvirtDomain.get_or_define_from_xml(new_resource.xml)
        domain.autostart(true)
        if !domain.active?
          converge_by("Start domain: #{new_resource}") do
            domain.start(new_resource.timeout)
          end
        end
      end
    end
  end
end

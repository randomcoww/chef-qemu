module QemuHelper
  class LibvirtDomain
    attr_reader :conn, :domain

    require 'libvirt'

    def initialize(domain, conn)
      @conn = conn
      @domain = domain
    end

    def self.get(name)
      domain = conn.lookup_domain_by_name(name)
      new(domain, conn)
    rescue
      nil
    end

    def self.define_from_xml(s)
      domain = conn.define_domain_xml(s)
      new(domain, conn)
    end

    ## hack to get any domains that conflict with this config
    ## try defining and undefine if successful
    ## return conflicting domain from error
    def self.get_current_from_xml(s)
      get_domain_from_error {
        domain = define_from_xml(s)
        domain.undefine
        nil
      }
    end

    def self.get_or_define_from_xml(s)
      get_domain_from_error {
        define_from_xml(s)
      }
    end

    def active?
      domain.active?
    end

    def autostart?
      domain.autostart
    end

    def shutdown_or_destroy(timeout)
      return true if !active?
      call_shutdown

      if check_with_timeout(timeout) { !active? }
        return true
      else
        call_destroy
        if check_with_timeout(timeout) { !active? }
          return true
        end
      end
      raise "Failed to stop domain #{domain.name}"
    end

    def start(timeout)
      return true if active?
      call_start

      if check_with_timeout(timeout) { active? }
        return true
      end
      raise "Failed to start domain #{domain.name}"
    end

    def shutdown_and_undefine(timeout)
      shutdown_or_destroy(timeout) if active?
      call_undefine if !active?
    end

    def set_autostart(bool)
      domain.autostart = !!bool
    end




    private

    def self.conn
      Libvirt::open('qemu:///system')
    end

    def self.get_all
      conn.list_all_domains.map do |dom|
        new(domain, conn)
      end
    end

    # def self.get_by_uuid(uuid)
    #   domain = conn.lookup_domain_by_uuid(uuid)
    #   new(domain, conn)
    # end

    def self.get_domain_from_error
      yield
    rescue Libvirt::DefinitionError => e
      if e.message =~ /already exists/
        domain_name = e.message.gsub(/.*? domain '(.*?)' already exists .*/, '\1')
        get(domain_name)
      end
    end

    def call_start
      domain.create
    end

    def call_shutdown
      domain.shutdown
    rescue Libvirt::Error => e
      return if e.message =~ /domain is not running/
      raise e
    end

    def call_destroy
      domain.destroy
    rescue Libvirt::Error => e
      return if e.message =~ /domain is not running/
      raise e
    end

    ## flag values
    # http://www.libvirt.org/html/libvirt-libvirt-domain.html#virDomainUndefineFlagsValues
    def call_undefine(flags=7)
      domain.undefine(flags)
    end

    def check_with_timeout(timeout)
      Timeout::timeout(timeout) {
        while true
          return true if yield
          sleep 1
        end
      }
    rescue Timeout::Error
      return false
    end
  end
end

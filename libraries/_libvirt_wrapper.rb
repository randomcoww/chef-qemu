module LibvirtWrapper
  class LibvirtDomain
    attr_reader :conn, :domain

    require 'libvirt'

    def initialize(domain, conn)
      @conn = conn
      @domain = domain
    end

    def self.get_by_name(name)
      d = conn.lookup_domain_by_name(name)
      new(d, conn)
    rescue
      nil
    end

    # def self.get_by_uuid(uuid)
    #   domain = conn.lookup_domain_by_uuid(uuid)
    #   new(domain, conn)
    # end

    def self.define_from_xml(s)
      d = conn.define_domain_xml(s)
      new(d, conn)
    end

    def self.get_or_define_from_xml(s)
      domain_from_error {
        define_from_xml(s)
      }
    end

    def self.get_all
      conn.list_all_domains.map do |d|
        new(d, conn)
      end
    end



    def valid?
      !domain.nil? && !domain.uuid.nil?
    rescue
      false
    end

    def active?
      valid? && domain.active?
    end

    def autostart?
      valid? && domain.autostart
    end



    def shutdown_or_destroy(timeout)
      call_shutdown

      if check_with_timeout(timeout) { !active? }
        return true
      elsif active?
        call_destroy
        if check_with_timeout(timeout) { !active? }
          return true
        end
      end
      raise "Failed to stop domain #{domain.name}"
    end

    def start(timeout)
      call_start if valid?

      if check_with_timeout(timeout) { active? }
        return true
      end
      raise "Failed to start domain #{domain.name}"
    end

    def shutdown_and_undefine(timeout)
      shutdown_or_destroy(timeout)
      call_undefine if valid?
    end

    def set_autostart(bool)
      call_autostart(bool) if valid?
    end




    private

    def self.conn
      Libvirt::open('qemu:///system')
    end

    def self.domain_from_error
      return yield
    rescue Libvirt::DefinitionError => e
      if e.message =~ /already exists/
        domain_name = e.message.gsub(/.*? domain '(.*?)' already exists .*/, '\1')
        return get_by_name(domain_name)
      end
      raise e
    end

    def call_start
      domain.create
    end

    def call_autostart(bool)
      domain.autostart = !!bool
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

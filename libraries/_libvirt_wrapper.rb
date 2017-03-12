module LibvirtWrapper
  class LibvirtDomain
    attr_accessor :domain

    require 'libvirt'

    def initialize(domain)
      @domain = domain
    end

    def self.get_by_name(name)
      new(conn.lookup_domain_by_name(name))
    end

    def self.get_or_define_from_xml(s)
      domain_from_error {
        new(conn.define_domain_xml(s))
      }
    end

    def exists?
      !domain.uuid.nil?
    rescue
      false
    end

    def active?
      domain.active?
    end

    def shutdown_or_destroy(timeout)
      domain.shutdown

      if check_with_timeout(timeout) { !active? }
        return true
      else
        domain.destroy
        if check_with_timeout(timeout) { !active? }
          return true
        end
      end
      raise "Failed to stop domain #{domain.name}"
    end

    def start(timeout)
      domain.create

      if check_with_timeout(timeout) { active? }
        return true
      end
      raise "Failed to start domain #{domain.name}"
    end

    def autostart(bool)
      domain.autostart = !!bool
    end




    private

    def self.conn
      Libvirt::open('qemu:///system')
    end

    def self.domain_from_error
      return yield
    rescue Libvirt::DefinitionError => e
      if e.message =~ /already exists/
        name = e.message.gsub(/.*? domain '(.*?)' already exists .*/, '\1')
        return new(conn.lookup_domain_by_name(name))
      end
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

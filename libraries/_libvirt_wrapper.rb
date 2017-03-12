module LibvirtWrapper
  class LibvirtDomain
    require 'libvirt'

    def self.get_by_name(name)
      conn.lookup_domain_by_name(name)
    rescue
      nil
    end

    def self.get_or_define_from_xml(s)
      domain_from_error {
        conn.define_domain_xml(s)
      }
    end

    def shutdown_or_destroy(timeout)
      shutdown

      if check_with_timeout(timeout) { !active? }
        return true
      else
        destroy
        if check_with_timeout(timeout) { !active? }
          return true
        end
      end
      raise "Failed to stop domain #{domain.name}"
    end

    def start(timeout)
      create

      if check_with_timeout(timeout) { active? }
        return true
      end
      raise "Failed to start domain #{domain.name}"
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
        return conn.lookup_domain_by_name(domain_name)
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

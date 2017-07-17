module LibvirtWrapper
  class LibvirtConn

    private

    def self.conn
      require 'libvirt'

      Libvirt::open('qemu:///system')
    end
  end


  ##
  ## domains
  ##
  class LibvirtDomain < LibvirtConn
    attr_accessor :domain

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

    def self.domain_from_error
      return yield
    rescue Libvirt::DefinitionError => e
      if e.message =~ /already exists/
        uuid = e.message.gsub(/.*? already exists with uuid (.+)$/, '\1')
        return new(conn.lookup_domain_by_uuid(uuid))
      else
        raise e
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


  ##
  ## domains
  ##
  class LibvirtNetwork < LibvirtConn
    attr_accessor :network

    def initialize(network)
      @network = network
    end

    def self.get_by_name(name)
      new(conn.lookup_network_by_name(name))
    end

    def self.get_or_define_from_xml(s)
      network_from_error {
        new(conn.define_network_xml(s))
      }
    end

    def exists?
      !network.uuid.nil?
    rescue
      false
    end

    def active?
      network.active?
    end

    def start
      network.create
    end

    def autostart(bool)
      network.autostart = !!bool
    end


    private

    def self.network_from_error
      return yield
    rescue Libvirt::DefinitionError => e
      if e.message =~ /already exists/
        uuid = e.message.gsub(/.*? already exists with uuid (.+)$/, '\1')
        return new(conn.lookup_network_by_uuid(uuid))
      else
        raise e
      end
    end
  end
end

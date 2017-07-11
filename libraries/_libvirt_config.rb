module LibvirtConfig
  class ConfigGenerator

    ## sample source
    # {
    #   "domain"=>{
    #     "#attributes"=>{
    #       "type"=>"kvm"
    #     },
    #     "name"=>"debian-test",
    #     "memory"=>{
    #       "#attributes"=>{
    #         "unit"=>"KiB"
    #       },
    #       "#text"=>"2097152"
    #     },
    #     "currentMemory"=>{
    #       "#attributes"=>{
    #         "unit"=>"KiB"
    #       },
    #       "#text"=>"2097152"
    #     },
    #     "vcpu"=>{
    #       "#attributes"=>{
    #         "placement"=>"static"
    #       },
    #       "#text"=>"2"
    #     },
    #     "iothreads"=>"1",
    #     "iothreadids"=>{
    #       "iothread"=>{
    #         "#attributes"=>{
    #           "id"=>"1"
    #         }
    #       }
    #     },
    #     "os"=>{
    #       "type"=>{
    #         "#attributes"=>{
    #           "arch"=>"x86_64",
    #           "machine"=>"pc-i440fx-2.8"
    #         },
    #         "#text"=>"hvm"
    #       },
    #       "boot"=>{
    #         "#attributes"=>{
    #           "dev"=>"hd"
    #         }
    #       }
    #     },
    #     "features"=>{
    #       "acpi"=>"",
    #       "apic"=>"",
    #       "pae"=>""
    #     },
    #     "cpu"=>{
    #       "#attributes"=>{
    #         "mode"=>"host-passthrough"
    #       },
    #       "topology"=>{
    #         "#attributes"=>{
    #           "sockets"=>"1",
    #           "cores"=>"2",
    #           "threads"=>"1"
    #         }
    #       }
    #     },
    #     "clock"=>{
    #       "#attributes"=>{
    #         "offset"=>"utc"
    #       }
    #     },
    #     "on_poweroff"=>"destroy",
    #     "on_reboot"=>"restart",
    #     "on_crash"=>"restart",
    #     "devices"=>{
    #       "emulator"=>"/usr/bin/qemu-system-x86_64",
    #       "disk"=>{
    #         "#attributes"=>{
    #           "type"=>"file",
    #           "device"=>"disk"
    #         },
    #         "driver"=>{
    #           "#attributes"=>{
    #             "name"=>"qemu",
    #             "type"=>"qcow2",
    #             "iothread"=>"1"
    #           }
    #         },
    #         "source"=>{
    #           "#attributes"=>{
    #             "file"=>"/img/kvm/debian-test.qcow2"
    #           }
    #         },
    #         "target"=>{
    #           "#attributes"=>{
    #             "dev"=>"vda",
    #             "bus"=>"virtio"
    #           }
    #         }
    #       },
    #       "controller"=>[
    #         {
    #           "#attributes"=>{
    #             "type"=>"usb",
    #             "index"=>"0",
    #             "model"=>"none"
    #           }
    #         },
    #         {
    #           "#attributes"=>{
    #             "type"=>"pci",
    #             "index"=>"0",
    #             "model"=>"pci-root"
    #           }
    #         }
    #       ],
    #       "filesystem"=>{
    #         "#attributes"=>{
    #           "type"=>"mount",
    #           "accessmode"=>"squash"
    #         },
    #         "source"=>{
    #           "#attributes"=>{
    #             "dir"=>"/img/secret/chef"
    #           }
    #         },
    #         "target"=>{
    #           "#attributes"=>{
    #             "dir"=>"chef-secret"
    #           }
    #         },
    #         "readonly"=>""
    #       },
    #       "interface"=>[
    #         {
    #           "#attributes"=>{
    #             "type"=>"bridge"
    #           },
    #           "source"=>{
    #             "#attributes"=>{
    #               "bridge"=>"eth0"
    #             }
    #           },
    #           "model"=>{
    #             "#attributes"=>{
    #               "type"=>"virtio-net"
    #             }
    #           }
    #         },
    #         {
    #           "#attributes"=>{
    #             "type"=>"bridge"
    #           },
    #           "source"=>{
    #             "#attributes"=>{
    #               "bridge"=>"eth1"
    #             }
    #           },
    #           "model"=>{
    #             "#attributes"=>{
    #               "type"=>"virtio-net"
    #             }
    #           }
    #         },
    #         {
    #           "#attributes"=>{
    #             "type"=>"bridge"
    #           },
    #           "source"=>{
    #             "#attributes"=>{
    #               "bridge"=>"eth2"
    #             }
    #           },
    #           "model"=>{
    #             "#attributes"=>{
    #               "type"=>"virtio-net"
    #             }
    #           }
    #         }
    #       ],
    #       "serial"=>{
    #         "#attributes"=>{
    #           "type"=>"pty"
    #         },
    #         "target"=>{
    #           "#attributes"=>{
    #             "port"=>"0"
    #           }
    #         }
    #       },
    #       "console"=>{
    #         "#attributes"=>{
    #           "type"=>"pty"
    #         },
    #         "target"=>{
    #           "#attributes"=>{
    #             "type"=>"serial",
    #             "port"=>"0"
    #           }
    #         }
    #       },
    #       "input"=>[
    #         {
    #           "#attributes"=>{
    #             "type"=>"mouse",
    #             "bus"=>"ps2"
    #           }
    #         },
    #         {
    #           "#attributes"=>{
    #             "type"=>"keyboard",
    #             "bus"=>"ps2"
    #           }
    #         }
    #       ],
    #       "memballoon"=>{
    #         "#attributes"=>{
    #           "model"=>"virtio"
    #         }
    #       }
    #     }
    #   }
    # }

    def self.generate_from_hash(config_hash)
      require 'nokogiri'

      g = new

      builder = Nokogiri::XML::Builder.new do |xml|
        config_hash.each do |k, v|
          g.parse_config_object(xml, k, v)
        end
      end
      builder.to_xml
    end

    def parse_config_object(xml, k, v)
      case v
      when Hash
        attributes = v.delete('#attributes') || {}
        text = v.delete('#text')

        if !text.nil?
          xml.send(k, text, attributes)
        else
          xml.send(k, attributes) {
            v.each do |e, f|
              parse_config_object(xml, e, f)
            end
          }
        end

      when Array
        v.each do |e|
          parse_config_object(xml, k, e)
        end

      when String,Integer
        xml.send(k, v)
      end
    end
  end
end

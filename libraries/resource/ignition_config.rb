class ChefQemu
  class Resource
    class IgnitionConfig < Chef::Resource
      include Ignition
      include SystemdHelper

      resource_name :qemu_ignition_config

      default_action :create
      allowed_actions :create, :delete

      property :networkd, Array, default: []
      property :systemd, Array, default: []
      property :systemd_dropins, Array, default: []
      property :files, Array, default: []
      property :base, Hash, default: {}

      property :exists, [TrueClass, FalseClass]
      property :path, String
      property :config, String, default: lazy { to_conf.to_json }

      private

      def to_conf
        base.to_hash.merge({
          "ignition" => {
            "version" => Ignition::VERSION,
            "config" => {}
          },
          "storage" => {
            "files" => files.map { |f|
              {
                "filesystem" => 'root',
                "path" => f['path'],
                "mode" => f['mode'],
                "contents" => {
                  "source" => f['contents']
                }
              }
            }
          },
          "networkd" => {
            "units" => networkd.map { |e|
              {
                "name" => "#{e['name']}.network",
                "contents" => SystemdHelper::ConfigGenerator.generate_from_hash(e['contents'])
              }
            }
          },
          "systemd" => {
            "units" => systemd.map { |e|
              {
                "enabled" => true,
                "name" => "#{e['name']}.service",
                "contents" => SystemdHelper::ConfigGenerator.generate_from_hash(e['contents'])
              }
            } + systemd_dropins.map { |e|
              {
                "enabled" => true,
                'dropins' => {
                  "name" => "#{e['name']}.service",
                  "contents" => SystemdHelper::ConfigGenerator.generate_from_hash(e['contents'])
                }
              }
            }
          }
        })
      end
    end
  end
end

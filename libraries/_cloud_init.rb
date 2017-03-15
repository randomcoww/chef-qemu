module CloudInit
  require 'iniparse'

  USER_DATA ||= 'user-data'
  META_DATA ||= 'meta-data'

  ## use same method as chef systemd-unit resource to parse this content
  # https://github.com/chef/chef/blob/master/lib/chef/resource/systemd_unit.rb#L48-L56
  def to_ini(content)
    IniParse.gen do |doc|
      content.each_pair do |sect, opts|
        doc.section(sect) do |section|
          opts.each_pair do |opt, val|
            section.option(opt, val)
          end
        end
      end
    end.to_s
  end
end

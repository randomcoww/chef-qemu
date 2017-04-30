module CloudInit
  require 'iniparse'

  USER_DATA ||= 'user-data'
  META_DATA ||= 'meta-data'

  def to_ini(c)
    ini_sections(c).join($/)
  end


  private

  def ini_sections(c, res=[])
    c.each_pair do |k, v|
      case v
      when Array
        v.each do |j|
          ini_sections({k => j}, res)
        end

      when Hash
        res << "[#{k}]"
        ini_options(v, res)
        res << ""
      end
    end
    res
  end

  def ini_options(c, res=[])
    c.each_pair do |k, v|
      case v
      when Array
        v.each do |j|
          ini_options({k => j}, res)
        end

      when Hash
        next

      when NilClass
        res << k

      else
        res << [k, v].join('=')
      end
    end
  end
end

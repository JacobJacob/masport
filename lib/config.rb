require 'yaml'

class Cfg

  @@path   = File.dirname(__FILE__)+'/../'
  @@config = YAML::load(File.open(@@path+'config/config.yaml'))

  def Cfg.get_path(path)
    @@path+@@config[path]
  end

  def Cfg.get(key)
    @@config[key]
  end

end

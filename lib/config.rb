require 'yaml'

class Cfg

  @@path   = File.dirname(__FILE__)+'/../'
  @@config = YAML::load(File.open(@@path+'config/config.yaml'))

  def Cfg.root_path
    @@path
  end

  def Cfg.get_config_path
    @@path+'/config/'
  end

  def Cfg.get_db_path
    @@path+@@config['db_path']
  end

  def Cfg.get_dns_path
    @@path+@@config['dns_path']
  end

  def Cfg.get_json_path
    @@path+@@config['json_path']
  end

end

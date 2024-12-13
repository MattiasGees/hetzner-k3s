class Configuration::NetworkingComponents::Cilium
  include YAML::Serializable
  include YAML::Serializable::Unmapped

  getter chart_version : String = "v1.16.4"

  def initialize
  end
end

require "../client"
require "./find"
require "../../util"
require "../../configuration/networking"

class Hetzner::Firewall::Create
  include Util

  private getter settings : Configuration::Main
  private getter hetzner_client : Hetzner::Client
  private getter firewall_name : String
  private getter firewall_finder : Hetzner::Firewall::Find
  private getter private_network : Configuration::NetworkingComponents::PrivateNetwork
  private getter ssh : Configuration::NetworkingComponents::SSH
  private getter allowed_networks : Configuration::NetworkingComponents::AllowedNetworks

  def initialize(
      @settings,
      @hetzner_client,
      @firewall_name,
    )
    @private_network = settings.networking.private_network
    @ssh = settings.networking.ssh
    @allowed_networks = settings.networking.allowed_networks
    @firewall_finder = Hetzner::Firewall::Find.new(hetzner_client, firewall_name)
  end

  def run
    firewall = firewall_finder.run
    action = firewall ? :update : :create

    if firewall
      log_line "Updating firewall..."
      action_path = "/firewalls/#{firewall.id}/actions/set_rules"
    else
      log_line "Creating firewall..."
      action_path = "/firewalls"
    end

    begin
      hetzner_client.post(action_path, firewall_config)
      log_line action == :update ? "...firewall updated" : "...firewall created"
    rescue ex : Crest::RequestFailed
      STDERR.puts "[#{default_log_prefix}] Failed to create or update firewall: #{ex.message}"
      exit 1
    end

    firewall = firewall_finder.run
    firewall.not_nil!
  end

  private def firewall_config
    rules = [
      {
        description: "Allow SSH port",
        direction: "in",
        protocol: "tcp",
        port: ssh.port.to_s,
        source_ips: allowed_networks.ssh,
        destination_ips: [] of String
      },
      {
        description: "Allow ICMP (ping)",
        direction: "in",
        protocol: "icmp",
        source_ips: [
          "0.0.0.0/0",
          "::/0"
        ],
        destination_ips: [] of String
      },
      {
        description: "Allow port 6443 (Kubernetes API server)",
        direction: "in",
        protocol: "tcp",
        port: "6443",
        source_ips: allowed_networks.api,
        destination_ips: [] of String
      }
    ]

    if private_network.enabled
      rules += [
        {
          description: "Allow all TCP traffic between nodes on the private network",
          direction: "in",
          protocol: "tcp",
          port: "any",
          source_ips: private_network.enabled ? [private_network.subnet] : [] of String,
          destination_ips: [] of String
        },
        {
          description: "Allow all UDP traffic between nodes on the private network",
          direction: "in",
          protocol: "udp",
          port: "any",
          source_ips: private_network.enabled ? [private_network.subnet] : [] of String,
          destination_ips: [] of String
        }
      ]
    end

    {
      name: firewall_name,
      rules: rules
    }
  end

  private def default_log_prefix
    "Firewall"
  end
end

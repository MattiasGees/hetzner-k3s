require "../client"
require "./find"
require "../../util"
require "../../configuration/networking"

class Hetzner::Firewall::Create
  include Util

  private getter settings : Configuration::Main
  private getter masters : Array(Hetzner::Instance)
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
      @masters
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

    Retriable.retry(max_attempts: 10, backoff: false, base_interval: 5.seconds) do
      success, response = hetzner_client.post(action_path, firewall_config)

      if success
        log_line action == :update ? "...firewall updated" : "...firewall created"
      else
        STDERR.puts "[#{default_log_prefix}] Failed to create or update firewall: #{response}"
        STDERR.puts "[#{default_log_prefix}] Retrying to create or update firewall in 5 seconds..."
        raise "Failed to create or update firewall"
      end
    end

    firewall = firewall_finder.run
    firewall.not_nil!
  end

  private def firewall_config
    rules = [
      {
        :description => "Allow SSH port",
        :direction => "in",
        :protocol =>  "tcp",
        :port => ssh.port.to_s,
        :source_ips => allowed_networks.ssh,
        :destination_ips => [] of String
      },
      {
        :description => "Allow ICMP (ping)",
        :direction => "in",
        :protocol =>  "icmp",
        :source_ips => [
          "0.0.0.0/0",
          "::/0"
        ],
        :destination_ips => [] of String
      },
      {
        :description => "Node port range",
        :direction => "in",
        :protocol =>  "tcp",
        :port => "30000-32767",
        :source_ips => [
          "0.0.0.0/0",
          "::/0"
        ],
        :destination_ips => [] of String
      },
      {
        :description => "Allow port 6443 (Kubernetes API server)",
        :direction => "in",
        :protocol =>  "tcp",
        :port => "6443",
        :source_ips => allowed_networks.api,
        :destination_ips => [] of String
      }
    ]

    if private_network.try(&.enabled)
      rules += [
        {
          :description => "Allow all TCP traffic between nodes on the private network",
          :direction => "in",
          :protocol =>  "tcp",
          :port => "any",
          :source_ips => [private_network.subnet],
          :destination_ips => [] of String
        },
        {
          :description => "Allow all UDP traffic between nodes on the private network",
          :direction => "in",
          :protocol =>  "udp",
          :port => "any",
          :source_ips => [private_network.subnet],
          :destination_ips => [] of String
        }
      ]
    else
      if settings.networking.cni.cilium?
        rules += [
          {
            :description => "Allow wireguard traffic (Cilium)",
            :direction => "in",
            :protocol =>  "tcp",
            :port => "51871",
            :source_ips => [
              "0.0.0.0/0",
              "::/0"
            ],
            :destination_ips => [] of String
          }
        ]
      else
        rules += [
          {
            :description => "Allow wireguard traffic",
            :direction => "in",
            :protocol =>  "tcp",
            :port => "51820",
            :source_ips => [
              "0.0.0.0/0",
              "::/0"
            ],
            :destination_ips => [] of String
          },
          {
            :description => "Allow wireguard traffic",
            :direction => "in",
            :protocol =>  "tcp",
            :port => "51821",
            :source_ips => [
              "0.0.0.0/0",
              "::/0"
            ],
            :destination_ips => [] of String
          }
        ]
      end

      if masters.size > 0 && settings.datastore.mode == "etcd"
        master_ips = masters.map do |master|
          "#{master.public_ip_address}/32"
        end

        rules << {
          :description => "Allow etcd traffic between masters",
          :direction => "in",
          :protocol =>  "tcp",
          :port => "2379",
          :source_ips => master_ips,
          :destination_ips => [] of String
        }

        rules << {
          :description => "Allow etcd traffic between masters",
          :direction => "in",
          :protocol =>  "tcp",
          :port => "2380",
          :source_ips => master_ips,
          :destination_ips => [] of String
        }
      end
    end

    if settings.embedded_registry_mirror.enabled
      rules << {
        :description => "Allow traffic between nodes for peer-to-peer image distribution",
        :direction => "in",
        :protocol =>  "tcp",
        :port => "5001",
        :source_ips => [
          "0.0.0.0/0",
          "::/0"
        ],
        :destination_ips => [] of String
      }
    end

    {
      :name => firewall_name,
      :rules => rules,
      :apply_to => [
        {
          :label_selector => {
            :selector => "cluster=#{settings.cluster_name}"
          },
          :type => "label_selector"
        }
      ]
    }
  end

  private def default_log_prefix
    "Firewall"
  end
end

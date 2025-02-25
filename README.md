![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/vitobotta/hetzner-k3s)
![GitHub Release Date](https://img.shields.io/github/release-date/vitobotta/hetzner-k3s)
![GitHub last commit](https://img.shields.io/github/last-commit/vitobotta/hetzner-k3s)
![GitHub issues](https://img.shields.io/github/issues-raw/vitobotta/hetzner-k3s)
![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/vitobotta/hetzner-k3s)
![GitHub](https://img.shields.io/github/license/vitobotta/hetzner-k3s)
![GitHub Discussions](https://img.shields.io/github/discussions/vitobotta/hetzner-k3s)
![GitHub top language](https://img.shields.io/github/languages/top/vitobotta/hetzner-k3s)

![GitHub forks](https://img.shields.io/github/forks/vitobotta/hetzner-k3s?style=social)
![GitHub Repo stars](https://img.shields.io/github/stars/vitobotta/hetzner-k3s?style=social)

---

```
 _          _                            _    _____
| |__   ___| |_ _____ __   ___ _ __     | | _|___ / ___
| '_ \ / _ \ __|_  / '_ \ / _ \ '__|____| |/ / |_ \/ __|
| | | |  __/ |_ / /| | | |  __/ | |_____|   < ___) \__ \
|_| |_|\___|\__/___|_| |_|\___|_|       |_|\_\____/|___/
```

# The easiest and fastest way to create production grade Kubernetes clusters in Hetzner Cloud

<p align="center">
  <img src="logo.png" alt="hetzner-k3s logo" width="200" height="200" style="margin-left: auto;">
</p>

## What is this?

This is a CLI tool to super quickly and super easily create and manage Kubernetes clusters in [Hetzner Cloud](https://www.hetzner.com/cloud) using the lightweight Kubernetes distribution [k3s](https://k3s.io/) from [Rancher](https://rancher.com/). In a recent test I created a 200 node HA cluster (3 masters, 197 worker nodes) in just **under 4 minutes** (when using only public network since private networks are limited to 100 instances per network). I believe this is a world record :)

Hetzner Cloud is an awesome cloud provider which offers a truly great service with the best performance/cost ratio in the market and locations in both Europe and USA.

k3s is my favorite Kubernetes distribution because it uses much less memory and CPU, leaving more resources to workloads. It is also super quick to deploy and upgrade because it's a single binary.

Using `hetzner-k3s`, creating a highly available k3s cluster with 3 masters for the control plane and 3 worker nodes takes **2-3 minutes** only. This includes

- creating all the infrastructure resources (instances, private network, firewall)
- deploying k3s to the nodes
- installing the [Hetzner Cloud Controller Manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager) to provision load balancers right away
- installing the [Hetzner CSI Driver](https://github.com/hetznercloud/csi-driver) to provision persistent volumes using Hetzner's block storage
- installing the [Rancher System Upgrade Controller](https://github.com/rancher/system-upgrade-controller) to make upgrades to a newer version of k3s easy and quick
- installing the [Cluster Autoscaler](https://github.com/kubernetes/autoscaler) to allow for autoscaling node pools

Also see this [documentation page](https://github.com/vitobotta/hetzner-k3s/blob/main/docs/Setting%20up%20a%20cluster.md) for a tutorial on how to set up a cluster with the most common setup to get you started.

___
## Who am I?

I'm the Lead Platform Architect for event management platform [Brella](https://www.brella.io/), based in Finland. I am responsible for all the technical aspects of the platform including development, infrastructure and mentoring developers. In my free time I act as a bug bounty hunter to find and responsibly disclose vulnerabilities in web applications.

See my public profile with links for connecting with me [here](https://vitobotta.com/).

---

## Docs

- [Installation](docs/Installation.md)
- [Creating a cluster](docs/Creating_a_cluster.md)
- [Masters in different locations](docs/Masters_in_different_locations.md)
- [Upgrading a 1.x cluster to 2.x](docs/Upgrading_a_cluster_from_1x_to_2x.md)
- [Setting up a cluster](docs/Setting%20up%20a%20cluster.md)
- [Recommendations](docs/Recommendations.md)
- [Maintenance](docs/Maintenance.md)
- [Deleting a cluster](docs/Deleting_a_cluster.md)
- [Load balancers](docs/Load_balancers.md)
- [Storage](docs/Storage.md)
- [Troubleshooting](docs/Troubleshooting.md)
- [Contributing and support](docs/Contributing_and_support.md)

---

## Sponsors

<p align="center">
  <img src="Alamos_black.svg" alt="hetzner-k3s logo" width="200" height="200" style="margin-left: auto;">
</p>

I want to give a big thank you to [**Alamos GmbH**](https://alamos.gmbh) for sponsoring this project! Their support has been incredibly helpful, giving me the chance to focus more time and effort on the work. Because of their contribution, I’ve been able to dedicate myself to creating a simpler migration strategy for moving clusters from v1.x to v2.x. I’m confident this collaboration will lead to even more improvements down the road. Thank you so much!

Also thanks to [@magicpages](https://github.com/magicpages), [@jonasbadstuebner](https://github.com/jonasbadstuebner), [@worldsayshi](https://github.com/worldsayshi), [@QuentinFAIDIDE](https://github.com/QuentinFAIDIDE) and the other sponsors. Your contributions are very much appreciated!

If you like this project and would like to help its development, consider [becoming a sponsor](https://github.com/sponsors/vitobotta) too.
___
## Code of conduct

Everyone interacting in the hetzner-k3s project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/vitobotta/hetzner-k3s/blob/main/CODE_OF_CONDUCT.md).

___
## License

This tool is available as open source under the terms of the [MIT License](https://github.com/vitobotta/hetzner-k3s/blob/main/LICENSE.txt).

___

## Stargazers over time

[![Stargazers over time](https://starchart.cc/vitobotta/hetzner-k3s.svg)](https://starchart.cc/vitobotta/hetzner-k3s)

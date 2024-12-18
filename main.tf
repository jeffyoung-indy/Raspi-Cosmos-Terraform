# Terraform main workflow
# This file initiates the modular setup for PCW|Integrates Smarthome System Development.

terraform {
  cloud {
    organization = "PcwIntegrates"
    workspaces {
      name = "ServingPi-Terraform"
    }
  }
}

provider "cloudflare" {
  # Configure Cloudflare provider with your API token
  api_token = var.cloudflare_api_token
}

provider "docker" {
  # Docker provider configuration for managing containers
  host = "unix:///var/run/docker.sock"
}

# 1Password integration for managing secure credentials
module "onepassword_integration" {
  source = "./modules/1password_integration"
  count  = var.install_onepassword ? 1 : 0
}

# 1Password Connect Server for API access across infrastructure
module "onepassword_connect_server" {
  source = "./modules/1password_connect_server"
  count  = var.install_onepassword_connect ? 1 : 0
}

# Cosmos Cloud setup for front-end management
module "cosmos_cloud_setup" {
  source = "./modules/cosmos_cloud_setup"
  count  = var.install_cosmos_cloud ? 1 : 0
  container_name = "cosmos-server"
  volumes = [
    "/var/run/docker.sock:/var/run/docker.sock",
    "/var/lib/cosmos:/config"
  ]
  network_mode = "host"
}

# Home Assistant setup for smart home integration (via Cosmos Market)
module "home_assistant_setup" {
  source = "./modules/home_assistant_setup"
  count  = var.install_home_assistant ? 1 : 0
}

# Node-RED setup for automation workflows (via Cosmos Market)
module "node_red_setup" {
  source = "./modules/node_red_setup"
  count  = var.install_node_red ? 1 : 0
}

# Grafana for analytics and data visualization (via Cosmos Market or DockerHub fallback)
module "grafana_setup" {
  source = "./modules/grafana_setup"
  count  = var.install_grafana ? 1 : 0
}

# Prometheus for monitoring and alerting (via Cosmos Market or DockerHub fallback)
module "prometheus_setup" {
  source = "./modules/prometheus_setup"
  count  = var.install_prometheus ? 1 : 0
}

# UniFi Network Server setup to integrate with Identity Enterprise (direct download fallback)
module "unifi_network_server_setup" {
  source = "./modules/unifi_network_server_setup"
  count  = var.install_unifi ? 1 : 0
}

# Cloudflare Workers for DDNS and additional services
module "cloudflare_workers" {
  source = "./modules/cloudflare_workers"
  count  = var.install_cloudflare_workers ? 1 : 0
}

# Pi-hole setup for DNS-based ad-blocking
module "pihole_setup" {
  source = "./modules/pihole"
  count  = var.install_pihole ? 1 : 0
}

# Credential Check Module
module "credential_check" {
  source = "./modules/credential_check"
  vault_name = var.onepassword_vault_name
  required_services = var.required_services
}

# VS Code Extensions Setup Module
module "vscode_extensions_setup" {
  source = "./modules/vscode_extensions_setup"
  count  = var.install_vscode ? 1 : 0
}
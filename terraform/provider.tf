terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

# Default Provider (Your 3-Node Cluster)
provider "proxmox" {
  alias		      = "ThePack"
  pm_api_url          = var.cluster_api_url
  pm_api_token_id     = var.cluster_api_token_id
  pm_api_token_secret = var.cluster_api_token_secret
  pm_tls_insecure     = true
}

# Alias Provider (Your Standalone Machine)
provider "proxmox" {
  alias               = "Lucky"
  pm_api_url          = var.standalone_api_url
  pm_api_token_id     = var.standalone_api_token_id
  pm_api_token_secret = var.standalone_api_token_secret
  pm_tls_insecure     = true
}

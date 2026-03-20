# Cluster Variables (ThePack)
variable "cluster_api_url" {
  type        = string
  description = "API URL for ThePack cluster (e.g., https://10.12.5.1:8006/api2/json)"
}

variable "cluster_api_token_id" {
  type = string
}

variable "cluster_api_token_secret" {
  type      = string
  sensitive = true
}

# Standalone Variables (Lucky)
variable "standalone_api_url" {
  type        = string
  description = "API URL for Lucky standalone (e.g., https://10.12.5.10:8006/api2/json)"
}

variable "standalone_api_token_id" {
  type = string
}

variable "standalone_api_token_secret" {
  type      = string
  sensitive = true
}

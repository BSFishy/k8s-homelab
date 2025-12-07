variable "vault_addr" {
  description = "The address of the Vault server"
  type        = string
  default     = "http://vault.vault-system.svc.cluster.local:8200"
}

variable "vault_token" {
  description = "The Vault token for authentication"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
  default     = "homelab"
}

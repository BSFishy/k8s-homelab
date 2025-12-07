provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

# Example: Enable Kubernetes auth method
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"

  description = "Kubernetes auth backend for ${var.cluster_name}"
}

# Example: Configure Kubernetes auth backend
resource "vault_kubernetes_auth_backend_config" "config" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
}

# Example: Create a base policy for read-only access to kv-v2
resource "vault_policy" "readonly" {
  name = "readonly"

  policy = <<EOT
# Allow read access to kv-v2 secrets
path "secret/data/*" {
  capabilities = ["read", "list"]
}

# Allow listing secret paths
path "secret/metadata/*" {
  capabilities = ["list"]
}
EOT
}

# Example: Create a base policy for app access
resource "vault_policy" "app_default" {
  name = "app-default"

  policy = <<EOT
# Default policy for applications
# Customize based on your needs

# Allow renewing tokens
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow revoking tokens
path "auth/token/revoke-self" {
  capabilities = ["update"]
}
EOT
}

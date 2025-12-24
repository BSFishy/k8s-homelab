provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"

  description = "Kubernetes auth backend for ${var.cluster_name}"
}

resource "vault_kubernetes_auth_backend_config" "config" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
}

resource "vault_kubernetes_auth_backend_role" "vault" {
  backend = vault_auth_backend.kubernetes.path
  role_name = "vault"
  bound_service_account_names = ["vault"]
  bound_service_account_namespaces = ["vault-system", "infra", "minecraft", "media"]

  token_policies = [vault_policy.vso.name]
}

resource "vault_policy" "vso" {
  name = "p-vso-infra"

  policy = <<EOT
path "database/static-creds/*" {
  capabilities = ["read"]
}

path "kv/data/curseforge/*" {
  capabilities = ["read"]
}

path "kv/metadata/curseforge/*" {
  capabilities = ["list", "read"]
}
EOT
}

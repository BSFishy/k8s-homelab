output "kubernetes_auth_path" {
  description = "The path where Kubernetes auth is mounted"
  value       = vault_auth_backend.kubernetes.path
}

# Vault Base Configuration

This Terraform configuration manages the base Vault setup including:

- Kubernetes authentication backend
- Base policies (readonly, app-default)
- Common Vault configuration

## Adding More Configuration

Add additional Terraform resources here for base vault configuration that doesn't depend on other services being up.

Examples:
- Authentication backends (OIDC, LDAP, etc.)
- Base policies and policy fragments
- Audit backends
- Secret engines that don't require external dependencies

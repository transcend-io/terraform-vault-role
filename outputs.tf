output vault_role_name {
  value       = vault_aws_auth_backend_role.role.role
  description = "The name of the Vault Role created"
}
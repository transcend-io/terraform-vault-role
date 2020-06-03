output vault_role_name {
  value = try(
    vault_aws_auth_backend_role.role[0].role,
    vault_approle_auth_backend_role.approle_role[0].role_name,
    ""
  )
  description = "The name of the Vault Role created"
}

output approle_accessor {
  value       = try(vault_approle_auth_backend_role_secret_id.approle_secret[0].accessor, "")
  description = "ID for approle logins"
}

output approle_wrapping_accessor {
  value       = try(vault_approle_auth_backend_role_secret_id.approle_secret[0].wrapping_accessor, "")
  description = "The unique ID for the response-wrapped SecretID that can be safely logged."
}

output approle_wrapping_token {
  value       = try(vault_approle_auth_backend_role_secret_id.approle_secret[0].wrapping_token, "")
  description = "The token used to retrieve a response-wrapped SecretID."
}

output approle_role_id {
  value       = try(vault_approle_auth_backend_role.approle_role[0].role_id, "")
  description = "ID of the approle created. This ID is auto-generated"
}
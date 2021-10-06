/**
 * Sets up a Vault role with permissions that a given set of IAM roles can access.
 */

locals {
  // Master source from named role => policies it generates
  named_rules = {
    # Allow reading Vault audit information, necessary to make a `terraform plan`, but not writing audit info
    audit_reader = [
      {
        path         = "/sys/audit"
        capabilities = ["read", "sudo"]
        description  = "Allow listing audit devices"
      },
    ],
    # Allow reading and writing Vault audit information
    audit_manager = [
      {
        path         = "/sys/audit"
        capabilities = ["read", "sudo"]
        description  = "Allow listing audit devices"
      },
      {
        path         = "/sys/audit/file"
        capabilities = ["create", "read", "update", "delete", "list", "sudo"]
        description  = "Allow creating a file audit devices"
      },
    ]
  }

  generated_rules = flatten([
    for given_rule in var.named_rules :
    lookup(local.named_rules, given_rule, [])
  ])
}

#######################
# AWS IAM Role Logins #
#######################

/**
 * Create a vault role that can be logged in to via an AWS IAM Role
 */
resource "vault_aws_auth_backend_role" "role" {
  for_each = length(var.login_role_arns) > 0 ? var.backend_paths : {}

  backend                  = each.key
  role                     = each.value
  auth_type                = "iam"
  bound_iam_principal_arns = var.login_role_arns
  resolve_aws_unique_ids   = false

  token_policies = [vault_policy.policy.name]
  token_ttl      = var.token_ttl
  token_max_ttl  = var.token_max_ttl
}

##################
# Approle Logins #
##################

resource "vault_approle_auth_backend_role" "approle_role" {
  for_each = var.enable_approle_login ? var.backend_paths : {}

  backend        = each.key
  role_name      = each.value
  bind_secret_id = true

  token_policies = [vault_policy.policy.name]
  token_ttl      = var.token_ttl
  token_max_ttl  = var.token_max_ttl
}

resource "vault_approle_auth_backend_role_secret_id" "approle_secret" {
  for_each = vault_approle_auth_backend_role.approle_role

  backend      = each.value.backend
  role_name    = each.value.role_name
  wrapping_ttl = var.wrapping_ttl
}

###########################
# Create the Vault Policy #
###########################

/**
 * Create a policy document to determine what access this role has in Vault
 */
data "vault_policy_document" "policy_doc" {
  dynamic "rule" {
    for_each = concat(var.rules, local.generated_rules)
    content {
      path         = rule.value.path
      capabilities = rule.value.capabilities
      description  = rule.value.description
    }
  }
}

/**
 * Create the Vault policy from the policy document
 */
resource "vault_policy" "policy" {
  name   = "${var.name}-policy"
  policy = data.vault_policy_document.policy_doc.hcl
}
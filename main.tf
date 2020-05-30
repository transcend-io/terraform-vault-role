/**
 * Sets up a Vault role with permissions that a given set of IAM roles can access.
 */

########################
# Vault side of things #
########################

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

/**
 * Create a vault role
 */
resource vault_aws_auth_backend_role role {
  backend                  = var.backend_path
  role                     = var.name
  auth_type                = "iam"
  bound_iam_principal_arns = var.login_role_arns
  resolve_aws_unique_ids   = false

  token_policies = [vault_policy.policy.name]
  token_ttl      = var.token_ttl
  token_max_ttl  = var.token_max_ttl
}

/**
 * Create a policy document to determine what access this role has in Vault
 */
data vault_policy_document policy_doc {
  dynamic rule {
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
resource vault_policy policy {
  name   = "${var.name}-policy"
  policy = data.vault_policy_document.policy_doc.hcl
}

######################
# AWS side of things #
######################

/**
 * JSON doc specifying that Vault can query data about some IAM Roles
 * that are used to log in to this Vault Role.
 */
data aws_iam_policy_document aws_get_role_doc {
  statement {
    sid       = "VaultAccessLoginRole"
    actions   = ["iam:GetRole"]
    resources = var.login_role_arns
  }
}

/**
 * Creates an AWS IAM Policy from the above doc.
 */
resource aws_iam_policy policy {
  name        = "${var.name}-policy"
  description = "Policy to allow Vault to lookup information on the AWS IAM Roles for Vault Role ${var.name}"
  policy      = data.aws_iam_policy_document.aws_get_role_doc.json
}

/**
 * Attaches the above policy to the Vault cluster instance profile role.
 */
resource aws_iam_role_policy_attachment aws_attachment {
  role       = var.instance_profile_role
  policy_arn = aws_iam_policy.policy.arn
}

variable backend_path {
  type        = string
  description = "Path to the aws backend"
}

variable name {
  type        = string
  description = "Name of the role in Vault"
}

variable login_role_arns {
  type        = list(string)
  description = "The ARNs of IAM Roles that should be able to access variables in this vault cluster"
}

variable named_rules {
  description = "List of common rules that have standard policies"
  type        = list(string)
  default     = []
}

variable rules {
  type = list(object({
    path         = string
    capabilities = list(string)
    description  = string
  }))
  default = []
}

variable instance_profile_role {
  type        = string
  description = "The name of the Instance Profile Role assigned to the EC2 instances in the Vault cluster in AWS"
}

variable token_ttl {
  type = number
  description = "The incremental lifetime for generated tokens in number of seconds. Its current value will be referenced at renewal time."
  default = 7200 # 20 hours
}

variable token_max_ttl {
  type = number
  description = "The maximum lifetime for generated tokens in number of seconds. Its current value will be referenced at renewal time"
  default = 7200 # 20 hours
}
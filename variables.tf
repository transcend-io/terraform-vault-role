variable "backend_paths" {
  type        = map(string)
  description = "map with paths to the aws backend as the keys, and names of the roles to create as the value"
}

variable "name" {
  type        = string
  description = "Name of the role in Vault"
}

variable "named_rules" {
  description = "List of common rules that have standard policies"
  type        = list(string)
  default     = []
}

variable "rules" {
  type = list(object({
    path               = string
    capabilities       = list(string)
    description        = string
    allowed_parameters = map(list(string))
    denied_parameters  = map(list(string))
  }))
  default = []
}

variable "token_ttl" {
  type        = number
  description = "The incremental lifetime for generated tokens in number of seconds. Its current value will be referenced at renewal time."
  default     = 72000 # 20 hours
}

variable "token_max_ttl" {
  type        = number
  description = "The maximum lifetime for generated tokens in number of seconds. Its current value will be referenced at renewal time"
  default     = 72000 # 20 hours
}

variable "wrapping_ttl" {
  type        = number
  description = "If Approle is enabled, the number of seconds after this module is applied where you can unwrap the secret_id"
  default     = 3600
}

#################
# Login Methods #
#################

variable "login_role_arns" {
  type        = list(string)
  description = "The ARNs of IAM Roles that should be able to access variables in this vault cluster"
  default     = []
}

variable "enable_approle_login" {
  type        = bool
  default     = false
  description = "If true, an approle auth method will be enabled"
}

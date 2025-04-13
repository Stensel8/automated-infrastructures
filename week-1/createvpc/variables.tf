############################################
# SSH / Key Pair variables, just to make sure SSH works. We're not using variable files at this point yet.
############################################

variable "user_home" {
  description = "The user's home directory (used to construct SSH key path)"
  type        = string
}

variable "ssh_key_name" {
  description = "The name of the public SSH key file"
  type        = string
  default     = "awskey.pub"
}

variable "public_key_path" {
  description = "Full path to the public SSH key used by the shared_key module"
  type        = string
}
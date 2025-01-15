variable "base_image" {
  type    = string
  default = "alpine"
}

variable "image_name" {
  type    = string
  default = "dev-tools"
}

variable "image_repository" {
  type    = string
  default = "dev-tools-builder"
}

variable "gcloud_version" {
  type    = string
  default = "505.0.0"
}

variable "packer_version" {
  type    = string
  default = "1.11.2"
}

variable "terraform_version" {
  type    = string
  default = "1.6.0"
}

variable "terragrunt_version" {
  type    = string
  default = "v0.54.12"
}

variable "version" {
  type        = string
  default     = ""
  description = "Optional version tag for the images"
}
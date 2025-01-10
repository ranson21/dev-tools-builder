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
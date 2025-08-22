variable "region" { type = string }
variable "project" { type = string }
variable "image_tag" { type = string, default = "latest" }
variable "memory_mb" { type = number, default = 512 }
variable "timeout_s" { type = number, default = 15 }
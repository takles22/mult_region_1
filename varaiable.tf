variable "region_1" {
  default = "us-west-1"
}

variable "region_2" {
  default = "us-east-1"
}

variable "profile_1" {
  default = "terraform-dev2"
}
variable "profile_2" {
  default = "terraform-dev"
}

variable "cidr_block1" {
  default = "10.0.0.0/16"
}

variable "cidr_block2" {
  default = "10.1.0.0/16"
}

variable "public_subnets1" {
  default = {
    us-west-1a = 10
  }
}

variable "public_subnets2" {
  default = {
    us-east-1a = 10
  }
}

variable "private_subnets1" {
  default = {
    us-west-1c = 100
  }
}

variable "private_subnets2" {
  default = {
    us-east-1b = 100
  }
}

variable "outgoing_cidr" {
    default = "0.0.0.0/0"
}

variable "docker_image_tag" {
  type        = string
  description = "This is the tag which will be used for the image that you created"
  default     = "latest"
}

variable "immutable_ecr_repositories" {
  type    = bool
  default = true
}


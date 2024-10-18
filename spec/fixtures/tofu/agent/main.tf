terraform {
  cloud {
    workspaces = ["fixtures-tofu-agent"]
  }

  required_providers {
    random = { source = "hashicorp/random"}
  }
}

resource "random_string" "testing" {
  length = 16
}

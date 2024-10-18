terraform {
  cloud {
    workspaces {
      name = "chushi-infra-workspace-testing"
    }
  }

  required_providers {
    random = { source = "hashicorp/random"}
  }
}

resource "random_string" "testing" {
  length = 16
}

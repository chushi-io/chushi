terraform {
  cloud {
    workspaces {
      name = "chushi-infra-workspace-testing-remote"
    }
  }

  required_providers {
    random = { source = "hashicorp/random"}
  }
}

resource "random_string" "testing" {
  length = 16
}

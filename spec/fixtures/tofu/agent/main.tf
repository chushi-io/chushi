terraform {
  cloud {
    workspaces {
      name = "chushi-infra-workspace-testing-agent"
    }
  }

  required_providers {
    random = { source = "hashicorp/random"}
  }
}

resource "random_string" "testing" {
  length = 16
}

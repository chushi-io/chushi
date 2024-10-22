terraform {
  cloud {
    organization = "chushi"
    hostname = "cloud.chushi.io"
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

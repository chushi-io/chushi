locals {
  organization = "my-cool-org"
  workspace = "workspace-1"
}
terraform {
#  cloud {
#    organization = "my-org"
#    hostname = "ceda-74-70-233-143.ngrok-free.app" # Optional; defaults to app.terraform.io
#
#    workspaces {
#      project = "testdata-workspace"
#      tags = ["networking", "source:cli"]
#    }
#  }
#  backend "remote" {
#    hostname = "caring-foxhound-whole.ngrok-free.app"
#    organization = "company"
#
#    workspaces {
#      name = "my-app-prod"
#    }
#  }
  backend "http" {
    address = "https://caring-foxhound-whole.ngrok-free.app/api/v1/orgs/my-cool-org/workspaces/workspace-1/state"
    lock_address = "https://caring-foxhound-whole.ngrok-free.app/api/v1/orgs/my-cool-org/workspaces/workspace-1"
    unlock_address = "https://caring-foxhound-whole.ngrok-free.app/api/v1/orgs/my-cool-org/workspaces/workspace-1"
  }
  required_version = "1.6.1"
}

resource "random_string" "test" {
  count = 8
  length = 8
}
package terraform

import input.run as run

deny[msg] {
    run.workspace.auto_apply != false
    msg := sprintf(
        "HCP Terraform workspace %s has been configured to automatically provision Terraform infrastructure. Change the workspace Apply Method settings to 'Manual Apply'",
        [run.workspace.name],
    )
}

import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";
import {Link, useParams} from "react-router-dom";
import {useOrganizations} from "../providers/OrganizationProvider";
import {Anchor, Breadcrumbs, Table} from "@mantine/core";


const ShowWorkspace = () => {
    const [workspace, setWorkspace] = useState({})
    const [runs, setRuns] = useState([])
    const orgs = useOrganizations()
    let { workspaceId } = useParams();

    useEffect(() => {
        if (orgs.currentOrganization === undefined) {
            return
        }
        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/workspaces/${workspaceId}`).then(res => {
            setWorkspace(res.data.workspace)
            axios.get(`/api/v1/orgs/${orgs.currentOrganization}/workspaces/${res.data.workspace.id}/runs`).then(res => {
                setRuns(res.data.runs)
            })
        })

    }, [orgs.currentOrganization])

    const triggerRun = () => {
        axios.post(`/api/v1/orgs/${orgs.currentOrganization}/workspaces/${workspace.id}/runs`, {
            operation: "plan"
        }).then(res => console.log(res.data))
    }

    return (
        <React.Fragment>
            {/*<h4>{workspace.name}</h4>*/}
            <Breadcrumbs>
                <Anchor component={Link} to={"/workspaces"}>Workspaces</Anchor>
                <Anchor component={Link} to={`/workspaces/${workspaceId}`}>{workspace.name}</Anchor>
                <Anchor component={Link} to={`/workspaces/${workspaceId}`}>Runs</Anchor>
            </Breadcrumbs>
            <Table withTableBorder={true}>
                <Table.Thead>
                    <Table.Tr>
                        <Table.Th>ID</Table.Th>
                        <Table.Th align="right">Status</Table.Th>
                        <Table.Th align="right">Add</Table.Th>
                        <Table.Th align="right">Change</Table.Th>
                        <Table.Th align="right">Destroy</Table.Th>
                        <Table.Th align="right">Resources</Table.Th>
                    </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                    {runs.map((run) => {
                        let color = "default"
                        let variant = "filled"
                        switch (run.status) {
                            case "completed":
                                color = "success"
                                break;
                            case "pending":
                                color = "primary"
                                variant = "outlined"
                                break;
                            case "failed":
                                color = "warning"
                                break;
                        }
                        return (
                          <Table.Tr key={run.id}>
                              <Table.Td>
                                  <Link to={`/runs/${run.id}`}>
                                      {run.id}
                                  </Link>
                              </Table.Td>
                              <Table.Td align="right">
                                  {/*<Chip size={"small"} label={run.status} color={color}/>*/}
                                  {run.status}
                              </Table.Td>
                              <Table.Td align="right">{run.add}</Table.Td>
                              <Table.Td align="right">{run.change}</Table.Td>
                              <Table.Td align="right">{run.destroy}</Table.Td>
                              <Table.Td align="right">{run.managed_resources}</Table.Td>
                          </Table.Tr>
                        )
                    })}
                </Table.Tbody>
            </Table>
            {/*<Button variant="outlined" onClick={triggerRun}>Trigger Run</Button>*/}
        </React.Fragment>
    )
}

export default ShowWorkspace;

import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";
import {Anchor, Breadcrumbs, Button, Skeleton} from '@mantine/core';
import { Table } from '@mantine/core';
import {Link} from "react-router-dom";
import {useOrganizations} from "../providers/OrganizationProvider";

const ListWorkspaces = () => {
    const [workspaces, setWorkspaces] = useState([])
    const [loading, setLoading] = useState(true)

    const orgs = useOrganizations()

    useEffect(() => {
        console.log(orgs)
        if (orgs.currentOrganization === undefined) {
            return
        }
        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/workspaces`).then(res => {
            setLoading(false)
            setWorkspaces(res.data.workspaces)
        })
    }, [orgs.currentOrganization])

    if (loading) {
        return <Skeleton height={8} radius="xl" />
    }

    return (
        <React.Fragment>
            <Breadcrumbs>
                <Anchor component={Link} to={"/workspaces"}>Workspaces</Anchor>
            </Breadcrumbs>
            <Table withTableBorder={true}>
                <Table.Thead>
                    <Table.Tr>
                        <Table.Th>Name</Table.Th>
                        <Table.Th align="right">Allow Destroy</Table.Th>
                        <Table.Th align="right">Auto Apply</Table.Th>
                        <Table.Th align="right">Locked</Table.Th>
                    </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                    {workspaces.map((workspace) => (
                      <Table.Tr key={workspace.id}>
                          <Table.Td>
                              <Link to={`/workspaces/${workspace.name}`}>
                                  {workspace.name}
                              </Link>
                          </Table.Td>
                          <Table.Td>{workspace.allow_destroy}</Table.Td>
                          <Table.Td>{workspace.auto_apply}</Table.Td>
                          <Table.Td>{workspace.locked}</Table.Td>
                      </Table.Tr>
                    ))}
                </Table.Tbody>
            </Table>

            <Button variant="outline" component={Link} to={"/workspaces/new"}>
                Create Workspace
            </Button>
        </React.Fragment>
    )
}

export default ListWorkspaces;

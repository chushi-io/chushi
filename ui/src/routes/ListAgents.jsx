import * as React from "react";
import {useEffect, useState} from "react";
import axios from "axios";
import {Link} from "react-router-dom";
import {useOrganizations} from "../providers/OrganizationProvider";
import {Anchor, Breadcrumbs, Table, Button } from "@mantine/core";

const ListAgents = () => {
    const [agents, setAgents] = useState([])
    const orgs = useOrganizations()
    useEffect(() => {
        if (orgs.currentOrganization === undefined) return;
        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/agents`).then(res => {
            setAgents(res.data.agents)
        })
    }, [orgs.currentOrganization])

    return (
        <React.Fragment>
            <Breadcrumbs>
                <Anchor component={Link} to={"/agents"}>Agents</Anchor>
            </Breadcrumbs>
            <Table withTableBorder={true}>
                <Table.Thead>
                    <Table.Tr>
                        <Table.Th>Name</Table.Th>
                        <Table.Th align="right">Client ID</Table.Th>
                    </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                    {agents.map((agent) => (
                      <Table.Tr key={agent.id}>
                          <Table.Td>
                              <Link to={`/agents/${agent.id}`}>
                                  {agent.id}
                              </Link>
                          </Table.Td>
                          <Table.Td>{agent.oauth_client_id}</Table.Td>
                      </Table.Tr>
                    ))}
                </Table.Tbody>
            </Table>

            <Button component={Link} to={"/agents/new"} variant={"outline"}>
                New Agent
            </Button>
        </React.Fragment>

    )
}

export default ListAgents;

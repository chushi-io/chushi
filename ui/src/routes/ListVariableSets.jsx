import * as React from "react";
import {Link} from "react-router-dom";
import {Button, Table} from '@mantine/core';
import {useEffect, useState} from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import axios from "axios";

const ListVariableSets = () => {
    const orgs = useOrganizations()
    const [variableSets, setVariableSets] = useState([])

    useEffect(() => {
        if (orgs.currentOrganization === undefined) {
            return
        }
        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/variable_sets`).then(res => setVariableSets(res.data.variable_sets))
    }, orgs.currentOrganization)
    return (
        <React.Fragment>
            <Table withTableBorder={true}>
                <Table.Thead>
                    <Table.Tr>
                        <Table.Th>Name</Table.Th>
                        <Table.Th align="right">Auto Attach</Table.Th>
                        <Table.Th align="right">Priority</Table.Th>
                    </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                    {variableSets.map((variableSet) => (
                      <Table.Tr key={variableSet.id}>
                          <Table.Td>
                              <Link to={`/variable_sets/${variableSet.id}`}>
                                  {variableSet.name}
                              </Link>
                          </Table.Td>
                          <Table.Td align="right">{variableSet.auto_attach}</Table.Td>
                          <Table.Td align="right">{variableSet.priority}</Table.Td>
                      </Table.Tr>
                    ))}
                </Table.Tbody>
            </Table>

            <Button component={Link} variant="outline" to={"/variable_sets/new"}>
                Create Variable Set
            </Button>
        </React.Fragment>
    )
}

export default ListVariableSets;

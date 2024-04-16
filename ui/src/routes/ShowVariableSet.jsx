import * as React from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import {Link, useParams} from "react-router-dom";
import {useEffect, useState} from "react";
import axios from "axios";
import {Button, Table} from "@mantine/core";

const ShowVariableSet = () => {
    const [variableSet, setVariableSet] = useState({});
    const orgs = useOrganizations();
    let { variableSetId } = useParams();

    useEffect(() => {
        if (orgs.currentOrganization === undefined) {
            return
        }

        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/variable_sets/${variableSetId}`)
            .then(res => setVariableSet(res.data.variable_set))
    }, orgs.currentOrganization)
    return (
        <React.Fragment>
            <Table withTableBorder={true}>
                <Table.Thead>
                    <Table.Tr>
                        <Table.Th>Name</Table.Th>
                        <Table.Th>Value</Table.Th>
                        <Table.Th>Sensitive</Table.Th>
                        <Table.Th>HCL</Table.Th>
                    </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                    {variableSet?.variables?.map((variable) => (
                      <Table.Tr key={variable.id}>
                          <Table.Td>
                              <Link to={`/variables/${variable.id}`}>
                                  {variable.name}
                              </Link>
                          </Table.Td>
                          <Table.Td align="right">{variable.value}</Table.Td>
                          <Table.Td align="right">{variable.sensitive}</Table.Td>
                          <Table.Td align="right">{variable.hcl}</Table.Td>
                      </Table.Tr>
                    ))}
                </Table.Tbody>
            </Table>

            <Button variant="outline" component={Link} to={`/variable_sets/${variableSetId}/variables/new`}>
                Add Variable
            </Button>
        </React.Fragment>

    )
}

export default ShowVariableSet;

import * as React from "react";
import {useOrganizations} from "../../providers/OrganizationProvider";
import {Anchor, Breadcrumbs, Table} from "@mantine/core";
import {Link} from "react-router-dom";

const Organizations = () => {
  const orgs = useOrganizations()

  return (
    <React.Fragment>
      <Breadcrumbs>
        <Anchor component={Link} to={"/settings/profile"}>Settings</Anchor>
        <Anchor component={Link} to={"/settings/organizations"}>Organizations</Anchor>
      </Breadcrumbs>
      <Table withTableBorder={true}>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>ID</Table.Th>
            <Table.Th>Name</Table.Th>
            <Table.Th>Type</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>
          {orgs.organizations.map((org) => (
            <Table.Tr key={org.id}>
              <Table.Td>
                <Link to={`/orgs/${org.id}`}>
                  {org.id}
                </Link>
              </Table.Td>
              <Table.Td>{org.name}</Table.Td>
              <Table.Td>{org.type}</Table.Td>
            </Table.Tr>
          ))}
        </Table.Tbody>
      </Table>
    </React.Fragment>
  )
}

export default Organizations;
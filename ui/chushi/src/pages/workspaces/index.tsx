import {Workspace} from "../../types";
import {apiClient} from "../../Client.tsx";
import {Alert, Anchor, Badge, Breadcrumbs, Container, Table} from "@mantine/core";
import {Link, useLoaderData, useParams} from "react-router-dom";

const Page = () => {
  let { organizationName } = useParams();

  const items = [
    { title: 'Workspaces', href: `organizations/${organizationName}/workspaces` },
  ].map((item, index) => (
    <Anchor to={item.href} key={index} component={Link}>
      {item.title}
    </Anchor>
  ));

  const workspaces = useLoaderData() as Workspace[]
  const rows = workspaces.map((element) => (
    <Table.Tr key={element.id}>
      <Table.Td>
        <Link to={`/${organizationName}/workspaces/${element.name}`}>{element.name}</Link>
      </Table.Td>
      <Table.Td>
        <Badge color={"blue"}>TBD</Badge>
      </Table.Td>
      <Table.Td>
        {element.terraformVersion}
      </Table.Td>
      {/*<Table.Td>{element.createdAt}</Table.Td>*/}
    </Table.Tr>
  ));

  if (workspaces.length == 0) {
    return (
      <Alert variant="light" color="blue">
        Oops, we don't have any workspaces yet! <Link to={`/${organizationName}/workspaces/new`}>Create one now</Link>
      </Alert>
    )
  }

  return (
    <Container>
      <Breadcrumbs separator=">" separatorMargin="md" mt="xs">
        {items}
      </Breadcrumbs>
      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>Name</Table.Th>
            <Table.Th>Status</Table.Th>
            <Table.Th>Tofu Version</Table.Th>
            {/*<Table.Th>Created At</Table.Th>*/}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </Container>
  )
}

const Loader = async ({ params }: { params: any}): Promise<Workspace[]> => {
  const { data: workspaces } = await apiClient.get(`/api/v2/organizations/${params.organizationName}/workspaces`)
  return workspaces as Workspace[];
}

export default {
  Page, Loader
}
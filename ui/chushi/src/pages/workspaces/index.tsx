import {Workspace} from "../../types";
import {apiClient} from "../../Client.tsx";
import {Anchor, Breadcrumbs, Container, Table} from "@mantine/core";
import {Link, useLoaderData, useParams} from "react-router-dom";

const Page = () => {
  let { organizationName } = useParams();

  const items = [
    { title: 'Workspaces', href: '#' },
  ].map((item, index) => (
    <Anchor href={item.href} key={index}>
      {item.title}
    </Anchor>
  ));

  const workspaces = useLoaderData() as Workspace[]
  const rows = workspaces.map((element) => (
    <Table.Tr key={element.id}>
      <Table.Td>
        <Link to={`/${organizationName}/workspaces/${element.name}`}>{element.name}</Link>
      </Table.Td>
      {/*<Table.Td>{element.email}</Table.Td>*/}
      {/*<Table.Td>{element.createdAt}</Table.Td>*/}
    </Table.Tr>
  ));
  return (
    <Container>
      <Breadcrumbs separator=">" separatorMargin="md" mt="xs">
        {items}
      </Breadcrumbs>
      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>Name</Table.Th>
            {/*<Table.Th>Email</Table.Th>*/}
            {/*<Table.Th>Created At</Table.Th>*/}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </Container>
  )
}

export const Loader = async ({ params }: { params: any}): Promise<Workspace[]> => {
  const { data: workspaces } = await apiClient.get(`/api/v2/organizations/${params.organizationName}/workspaces`)
  return workspaces as Workspace[];
}

export default {
  Page, Loader
}
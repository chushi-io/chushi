import { Organization } from "../../types";
import {Link, useLoaderData} from "react-router-dom";
import {Anchor, Breadcrumbs, Container, Table} from "@mantine/core";
import {apiClient} from "../../Client.tsx";
const Page = () => {
  const items = [
    { title: 'Organizations', href: '#' },
  ].map((item, index) => (
    <Anchor href={item.href} key={index}>
      {item.title}
    </Anchor>
  ));

  const organizations = useLoaderData() as Organization[]
  const rows = organizations.map((element) => (
    <Table.Tr key={element.id}>
      <Table.Td>
        <Link to={`/organizations/${element.name}`}>{element.name}</Link>
      </Table.Td>
      <Table.Td>{element.email}</Table.Td>
      <Table.Td>{element.createdAt}</Table.Td>
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
            <Table.Th>Email</Table.Th>
            <Table.Th>Created At</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </Container>
  )
}

const Loader = async (_args: any, _handlerCtx?: unknown): Promise<Organization[]> => {
  const { data: organizations } = await apiClient.get('/api/v2/organizations')
  return organizations as Organization[];
}

export default {
  Page,
  Loader
}
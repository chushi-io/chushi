import {Policy} from "../../types";
import {apiClient} from "../../Client.tsx";
import {Link, useLoaderData, useParams} from "react-router-dom";
import {Anchor, Container, Table} from "@mantine/core";
import PageHeader from "../../components/PageHeader";

const Page = () => {
  let { organizationName } = useParams();

  const items = [
    { title: 'Policies', href: `organizations/${organizationName}/policies` },
  ].map((item, index) => (
    <Anchor to={item.href} key={index} component={Link}>
      {item.title}
    </Anchor>
  ));


  const policies = useLoaderData() as Policy[]
  const rows = policies.map((element: Policy) => {
    return <Table.Tr key={element.id}>
      <Table.Td>
        <Link to={`/${organizationName}/policies/${element.id}`}>{element.name}</Link>
      </Table.Td>
      <Table.Td>{element.kind}</Table.Td>
      <Table.Td>{element.query}</Table.Td>
      <Table.Td>{element.enforcementLevel}</Table.Td>
    </Table.Tr>
  })

  return (
    <Container fluid>
      <PageHeader
        breadcrumbs={items}
        primaryAction={{
          children: "New Policy",
          to: `/${organizationName}/policies/new`,
          component: Link,
        }}
      />

      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>Name</Table.Th>
            <Table.Th>Kind</Table.Th>
            <Table.Th>Query</Table.Th>
            <Table.Th>Enforcement</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </Container>
  )
}

const Loader = async ({ params }: { params: any}): Promise<Policy[]> => {
  const { data: policies } = await apiClient.get(`/api/v2/organizations/${params.organizationName}/policies`)
  return policies as Policy[];
}

export default { Page, Loader }

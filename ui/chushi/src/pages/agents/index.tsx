import {apiClient} from "../../Client.tsx";
import {AgentPool} from "../../types";
import {Link, useLoaderData, useParams} from "react-router-dom";
import {Anchor, Badge, Container, Table} from "@mantine/core";
import PageHeader from "../../components/PageHeader";


const Page = () => {
  let { organizationName } = useParams();
  console.log(organizationName)
  const agentPools = useLoaderData() as AgentPool[]

  const items = [
    { title: 'Agent Pools', href: `organizations/${organizationName}/agent-pools` },
  ].map((item, index) => (
    <Anchor to={item.href} key={index} component={Link}>
      {item.title}
    </Anchor>
  ));

  const rows = agentPools.map((element) => (
    <Table.Tr key={element.id}>
      <Table.Td>
        <Link to={`/${organizationName}/agent-pools/${element.id}`}>{element.name}</Link>
      </Table.Td>
      <Table.Td>
        <Badge color={"blue"}>TBD</Badge>
      </Table.Td>
      <Table.Td>
        {element.organizationScoped}
      </Table.Td>
      {/*<Table.Td>{element.createdAt}</Table.Td>*/}
    </Table.Tr>
  ));

  // <Button to={"/organizations/new"} component={Link}>New Organization</Button>
  return (
    <Container fluid>
      <PageHeader
        breadcrumbs={items}
        primaryAction={{
          children: "New Agent",
          to: `/${organizationName}/agent-pools/new`,
          component: Link,
        }}
      />

      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>Name</Table.Th>
            <Table.Th>Status</Table.Th>
            <Table.Th>Organization Scoped</Table.Th>
            <Table.Th>Created At</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </Container>
  )
}

const Loader = async ({ params }: { params: any}): Promise<AgentPool[]> => {
  const { data: agentPools } = await apiClient.get(`/api/v2/organizations/${params.organizationName}/agent-pools`)
  return agentPools as AgentPool[];
}

export default { Page, Loader }
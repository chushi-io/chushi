import {Link, useLoaderData, useParams} from "react-router-dom";
import {Anchor, Container, Table} from "@mantine/core";
import PageHeader from "../../components/PageHeader";
import {RunTask} from "../../types";
import {apiClient} from "../../Client.tsx";

const Page = () => {
  let { organizationName } = useParams();
  const runTasks = useLoaderData() as RunTask[]

  const items = [
    { title: 'Run Tasks', href: `/organizations/${organizationName}/tasks` },
  ].map((item, index) => (
    <Anchor to={item.href} key={index} component={Link}>
      {item.title}
    </Anchor>
  ));

  const rows = runTasks.map((element) => (
    <Table.Tr key={element.id}>
      <Table.Td>
        <Link to={`/${organizationName}/tasks/${element.id}`}>{element.name}</Link>
      </Table.Td>
      <Table.Td>{element.url}</Table.Td>
    </Table.Tr>
  ));

  return (
    <Container fluid>
      <PageHeader
        breadcrumbs={items}
        primaryAction={{
          children: "New Run Task",
          to: `/${organizationName}/tasks/new`,
          component: Link,
        }}
      />
      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>Name</Table.Th>
            <Table.Th>URL</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </Container>
  )
}

const Loader = async ({ params }: { params: any}): Promise<RunTask[]> => {
  const { data: runTasks } = await apiClient.get(`/api/v2/organizations/${params.organizationName}/tasks`)
  return runTasks as RunTask[];
}

export default { Page, Loader }
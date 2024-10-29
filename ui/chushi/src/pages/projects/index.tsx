import {apiClient} from "../../Client.tsx";
import {Project} from "../../types";
import {Link, useLoaderData, useParams} from "react-router-dom";
import {Anchor, Badge, Container, Table} from "@mantine/core";
import PageHeader from "../../components/PageHeader";

const Page = () => {
  let { organizationName } = useParams();
  const projects = useLoaderData() as Project[]

  const items = [
    { title: 'Projects', href: `organizations/${organizationName}/projects` },
  ].map((item, index) => (
    <Anchor to={item.href} key={index} component={Link}>
      {item.title}
    </Anchor>
  ));

  const rows = projects.map((element) => (
    <Table.Tr key={element.id}>
      <Table.Td>
        <Link to={`/${organizationName}/projects/${element.id}`}>{element.name}</Link>
      </Table.Td>
      <Table.Td>
        <Badge color={"blue"}>TBD</Badge>
      </Table.Td>
    </Table.Tr>
  ));

  return (
    <Container fluid>
      <PageHeader
        breadcrumbs={items}
        primaryAction={{
          children: "New Project",
          to: `/${organizationName}/projects/new`,
          component: Link,
        }}
        />
      <Table>
        <Table.Thead>
          <Table.Tr>
            <Table.Th>Name</Table.Th>
            <Table.Th>Status</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </Container>
  )
}

const Loader = async ({ params }: { params: any}): Promise<Project[]> => {
  const { data: projects } = await apiClient.get(`/api/v2/organizations/${params.organizationName}/projects`)
  return projects as Project[];
}

export default { Page, Loader }
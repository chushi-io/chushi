import {Link, useLoaderData, useParams} from "react-router-dom";
import {Run, Workspace} from "../../types";
import {apiClient} from "../../Client.tsx";
import {Anchor, Badge, Breadcrumbs, Button, Container, Grid, Menu, Table, Tabs} from "@mantine/core";
import {useEffect, useState} from "react";

const Page = () => {
  let { organizationName, workspaceName } = useParams();
  const workspace = useLoaderData() as Workspace

  const items = [
    { title: 'Workspaces', href: `/${organizationName}/workspaces` },
    { title: workspaceName, href: `/${organizationName}/${workspaceName}` },
  ].map((item, index) => (
    <Anchor to={item.href} key={index} component={Link}>
      {item.title}
    </Anchor>
  ));

  return (
    <Container fluid>
      <Breadcrumbs separator=">" separatorMargin="md" mt="xs">
        {items}
      </Breadcrumbs>
      <Grid>
        <Grid.Col span={8}>
          <h4>{workspaceName}</h4>
          <p>ID: {workspace.id}</p>
        </Grid.Col>
        <Grid.Col span={4}>
          <Menu shadow="md" width={200}>
            <Menu.Target>
              <Button variant={"default"}>Actions</Button>
            </Menu.Target>

            <Menu.Dropdown>
              <Menu.Item>Settings</Menu.Item>
              <Menu.Item>Access</Menu.Item>
              {workspace.locked && <Menu.Item>Unlock</Menu.Item> }
              {workspace.locked || <Menu.Item>Locked</Menu.Item> }

            </Menu.Dropdown>
          </Menu>
          <Button>Create Run</Button>
        </Grid.Col>
      </Grid>

      <Tabs defaultValue="runs">
        <Tabs.List>
          <Tabs.Tab value="runs">
            Runs
          </Tabs.Tab>
          <Tabs.Tab value="events">
            Events
          </Tabs.Tab>
          <Tabs.Tab value="state">
            State
          </Tabs.Tab>
          <Tabs.Tab value="access">
            Access
          </Tabs.Tab>
        </Tabs.List>

        <Tabs.Panel value="runs">
          <RunsTab workspace={workspace} organizationName={organizationName} />
        </Tabs.Panel>
        <Tabs.Panel value="events">
          <EventsTab />
        </Tabs.Panel>
        <Tabs.Panel value="state">
          <StateTab />
        </Tabs.Panel>
        <Tabs.Panel value={"access"}>
          <AccessTab />
        </Tabs.Panel>
      </Tabs>
    </Container>
  )
}

const RunsTab = (props: any) => {
  const { workspace, organizationName } = props
  const [runs, setRuns] = useState<Run[]>([])

  useEffect(() => {
    apiClient.get(`/api/v2/workspaces/${workspace.id}/runs`).then(res => {
      setRuns(res.data)
    })
    // Get our runs and set them...
    setRuns([])
  }, [])
  const rows = runs.map(run => {
    return <Table.Tr key={run.id}>
      <Table.Td>
        <Link to={`/${organizationName}/${workspace.name}/runs/${run.id}`}>{run.message || "Triggered by CLI"}</Link>
      </Table.Td>
      <Table.Td>
        <Badge color={"blue"}>TBD</Badge>
      </Table.Td>
      <Table.Td>

      </Table.Td>
      {/*<Table.Td>{element.createdAt}</Table.Td>*/}
    </Table.Tr>
  })
  return <Table>
    <Table.Thead>
      <Table.Tr>
        <Table.Th>Message</Table.Th>
        <Table.Th>Status</Table.Th>
        <Table.Th>Tofu Version</Table.Th>
        {/*<Table.Th>Created At</Table.Th>*/}
      </Table.Tr>
    </Table.Thead>
    <Table.Tbody>{rows}</Table.Tbody>
  </Table>
}

const EventsTab = () => {
  return <h4>Viewing events configuration</h4>
}

const StateTab = () => {
  return <h4>Viewing state information</h4>
}

const AccessTab = () => {
  return <h4>Managing access</h4>
}

const Loader = async({params}: { params: any}): Promise<Workspace> => {
  const { data: workspace } = await apiClient.get(`/api/v2/organizations/${params.organizationName}/workspaces/${params.workspaceName}`)
  return workspace
}

export default {
  Page, Loader
}
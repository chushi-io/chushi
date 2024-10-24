import {useDisclosure} from "@mantine/hooks";
import {Fragment, useEffect, useState} from "react";
import {Link, Outlet} from "react-router-dom";
import {AppShell, ScrollArea, Select} from "@mantine/core";
import {apiClient} from "../Client.tsx";
import {Organization} from "../types";
export default () => {
  const [organizations, setOrganizations] = useState<Organization[]>([])
  const [organization, setOrganization] = useState<Organization>()

  useEffect(() => {
    apiClient.get('/api/v2/organizations').then(res => {
      setOrganizations(res.data)
      // TODO: Obviously we should select this from somewhere
      setOrganization(res.data[0])
    })
  }, [])
  const [opened, _] = useDisclosure();

  console.log(organizations)

  return (
    <Fragment>
      <AppShell
        header={{ height: 60 }}
        navbar={{ width: 300, breakpoint: 'sm', collapsed: { mobile: !opened } }}
        padding="md"
      >
        <AppShell.Header>
          <Select
            data={organizations.map((org) => org.name)}
          />
        </AppShell.Header>

        <AppShell.Navbar>
          <AppShell.Section>Navbar header</AppShell.Section>
          <AppShell.Section grow component={ScrollArea}>
            <Link to={"organizations"}>Organizations</Link>
            <Link to={`/${organization?.name}/workspaces`}>Workspaces</Link>
          </AppShell.Section>
          <AppShell.Section>
            Navbar footer – always at the bottom
          </AppShell.Section>
        </AppShell.Navbar>

        <AppShell.Main>
          <Outlet />
        </AppShell.Main>
      </AppShell>
    </Fragment>
  );
}
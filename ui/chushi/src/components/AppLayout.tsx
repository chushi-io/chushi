// import {useDisclosure} from "@mantine/hooks";
import {Fragment, useEffect, useState} from "react";
import {Link, Outlet, useNavigate} from "react-router-dom";
import {AppShell, ScrollArea, Select} from "@mantine/core";
import {apiClient} from "../Client.tsx";
import {Organization} from "../types";
import {IconGauge} from "@tabler/icons-react";

import classes from './AppLayout.module.css';

export default () => {
  const navigate = useNavigate();
  const [organizations, setOrganizations] = useState<Organization[]>([])
  const [organization, setOrganization] = useState<string | null>("")

  useEffect(() => {
    apiClient.get('/api/v2/organizations').then(res => {
      setOrganizations(res.data)

      // TODO: Obviously we should select this from somewhere
      setOrganization(res.data[0].name)
    })
  }, [])
  // const [_, _] = useDisclosure();

  const linkData = [
    { icon: IconGauge, label: 'Workspaces', href: `/${organization}/workspaces` },
    { icon: IconGauge, label: 'Variable Set', href: `/${organization}/variable-sets` },
    { icon: IconGauge, label: 'VCS Connections', href: `/${organization}/vcs-connections`  },
    { icon: IconGauge, label: 'Registry', href: '#' },
    { icon: IconGauge, label: 'Agents', href: `/${organization}/agent-pools` },
    { icon: IconGauge, label: 'Organizations', href: '/organizations'  },
    { icon: IconGauge, label: 'Policy Sets', href: `/${organization}/policy-sets` },
    { icon: IconGauge, label: 'Run Tasks', href: `/${organization}/tasks` },
    { icon: IconGauge, label: 'Projects', href: `/${organization}/projects` },
  ];

  const links = linkData.map((link) => (
    <Link
      className={classes.link}
      // data-active={activeLink === link || undefined}
      to={link.href}
      // onClick={(event) => {
      //   event.preventDefault();
      //   setActiveLink(link);
      // }}
      key={link.label}
    >
      {link.label}
    </Link>
  ));

  return (
    <Fragment>
      <AppShell
        header={{ height: 60 }}
        navbar={{ width: 300, breakpoint: 'sm' }}
        padding="md"
      >
        <AppShell.Header>

        </AppShell.Header>

        <AppShell.Navbar>
          {/*<AppShell.Section>Navbar header</AppShell.Section>*/}
          <AppShell.Section grow component={ScrollArea}>
            {links}
          </AppShell.Section>
          <AppShell.Section>
            <Select
              data={organizations.map((org) => org.name)}
              value={organization}
              onChange={(value) => {
                setOrganization(value)
                navigate(`/${value}/workspaces`);
              }}
            />
          </AppShell.Section>
        </AppShell.Navbar>

        <AppShell.Main>
          <Outlet />
        </AppShell.Main>
      </AppShell>
    </Fragment>
  );
}
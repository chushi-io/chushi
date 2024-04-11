import {AppShell, NavLink, Select} from '@mantine/core';
import {Link, Outlet} from "react-router-dom";
import * as React from "react";
import {useOrganizations} from "../providers/OrganizationProvider";

export default () => {
    const context = useOrganizations()
    return (
      <AppShell
        header={{ height: 60 }}
        navbar={{
            width: 300,
            breakpoint: 'sm',
        }}
        padding="md"
      >
          <AppShell.Header>
              <div>Chushi</div>
          </AppShell.Header>

          <AppShell.Navbar p="md">
              <Select
                data={context.organizations.map(org => {
                    return { value: org.id, label: org.name }
                })}
                value={context.currentOrganization}
                onChange={(_value, option) => {
                    console.log(_value)
                    console.log(option)
                    context.changeOrganization(_value)
                }}
              />
              <NavLink component={Link} to={"/workspaces"} label={"Workspaces"} />
              <NavLink component={Link} to={"/agents"} label={"Agents"} />
              <NavLink component={Link} to={"/registry"} label={"Registry"} />
              <NavLink component={Link} to={"/settings"} label={"Settings"} />
              <NavLink component={Link} to={"/organizations"} label={"Organizations"} />
              <NavLink component={Link} to={"/vcs_connections"} label={"Connections"} />
              <NavLink component={Link} to={"/variables"} label={"Variables"} />
              <NavLink component={Link} to={"/variable_sets"} label={"Variable Sets"} />
          </AppShell.Navbar>

          <AppShell.Main>
              <Outlet />
          </AppShell.Main>
      </AppShell>
    );
}
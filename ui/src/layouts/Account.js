import {AppShell, NavLink, Select} from '@mantine/core';
import {Link, Outlet} from "react-router-dom";
import * as React from "react";

export default () => {
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
        <NavLink component={Link} to={"/settings/profile"} label={"Account"} />
        <NavLink component={Link} to={"/settings/billing"} label={"Billing"} />
        <NavLink component={Link} to={"/settings/organizations"} label={"Organizations"} />
        <NavLink component={Link} to={"/settings/mfa"} label={"Multi Factor Authentication"} />
        <NavLink component={Link} to={"/settings/access_tokens"} label={"Access Tokens"} />
      </AppShell.Navbar>

      <AppShell.Main>
        <Outlet />
      </AppShell.Main>
    </AppShell>
  );
}
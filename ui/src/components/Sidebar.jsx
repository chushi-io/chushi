import * as React from "react";
import {Link} from "react-router-dom";
import {OrganizationContext, useOrganizations} from "../providers/OrganizationProvider";

const NavigationSidebar = () => {
    const context = useOrganizations()

    console.log(context.organizations)
    console.log(context.currentOrganization)
    return (
        <React.Fragment>
            <Sidebar className="app">
                <Menu>
                    <MenuItem className="menu1">
                        <h2>Chushi</h2>
                    </MenuItem>
                    <MenuItem>
                        <FormControl>
                            <Select
                                value={context.currentOrganization}
                                label={"Organization"}
                                onChange={(event) => {
                                    console.log(event.target.value)
                                    context.changeOrganization(event.target.value)
                                }}
                            >
                                {context.organizations.map(org => {
                                    return <MenuItem value={org.id}>{org.name}</MenuItem>
                                })}
                            </Select>
                        </FormControl>
                    </MenuItem>
                    <MenuItem> <Link to={"/workspaces"}>Workspaces</Link> </MenuItem>
                    <MenuItem> <Link to={"/agents"}>Agents</Link> </MenuItem>
                    <MenuItem> <Link to={"/registry"}>Registry</Link> </MenuItem>
                    <MenuItem> <Link to={"/settings"}>Settings</Link> </MenuItem>
                    <MenuItem> <Link to={"/organizations"}>Organizations</Link> </MenuItem>
                    <MenuItem> <Link to={"/vcs_connections"}>VCS Connections</Link> </MenuItem>
                    <MenuItem> <Link to={"/variables"}>Variables</Link> </MenuItem>
                    <MenuItem> <Link to={"/variable_sets"}>Variable Sets</Link> </MenuItem>
                </Menu>

            </Sidebar>
            {/*<Box sx={{ display: "flex" }}>*/}
            {/*        <AppBar position={"static"}>*/}
            {/*            <Toolbar>*/}
            {/*                <IconButton*/}
            {/*                    size="large"*/}
            {/*                    edge="start"*/}
            {/*                    color="inherit"*/}
            {/*                    aria-label="menu"*/}
            {/*                    sx={{ mr: 2 }}*/}
            {/*                >*/}
            {/*                    <MenuIcon />*/}
            {/*                </IconButton>*/}
            {/*                <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>*/}
            {/*                    <Link to={"/workspaces"}>Workspaces</Link>*/}
            {/*                    <Link to={"/agents"}>Agents</Link>*/}
            {/*                </Typography>*/}
            {/*                <Button color="inherit">Login</Button>*/}
            {/*            </Toolbar>*/}
            {/*        </AppBar>*/}
            {/*</Box>*/}
        </React.Fragment>
    )
}

export default NavigationSidebar;

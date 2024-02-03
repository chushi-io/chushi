import * as React from "react";
import { Sidebar, Menu, MenuItem } from "react-pro-sidebar";
import {Link} from "react-router-dom";

const NavigationSidebar = () => {
    return (
        <Sidebar className="app">
            <Menu>
                <MenuItem className="menu1">
                    <h2>Chushi</h2>
                </MenuItem>
                <MenuItem> <Link to={"/workspaces"}>Workspaces</Link> </MenuItem>
                <MenuItem> <Link to={"/agents"}>Agents</Link> </MenuItem>
                <MenuItem> <Link to={"/registry"}>Registry</Link> </MenuItem>
                <MenuItem> <Link to={"/settings"}>Settings</Link> </MenuItem>
            </Menu>
        </Sidebar>
    )
}

export default NavigationSidebar;

import * as React from "react";
import { Sidebar, Menu, MenuItem } from "react-pro-sidebar";

const NavigationSidebar = () => {
    return (
        <Sidebar className="app">
            <Menu>
                <MenuItem className="menu1">
                    <h2>QUICKPAY</h2>
                </MenuItem>
                <MenuItem> Workspaces </MenuItem>
                <MenuItem> Agents </MenuItem>
                <MenuItem> Registry </MenuItem>
                <MenuItem> Settings </MenuItem>
            </Menu>
        </Sidebar>
    )
}

export default NavigationSidebar;

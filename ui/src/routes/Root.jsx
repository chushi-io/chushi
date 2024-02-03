import * as React from "react";
import Sidebar from "../components/Sidebar";
import {Outlet} from "react-router-dom";

const Root = () => {
    return (
        <div style={{display: "flex", height: "100vh"}}>
            <Sidebar>

            </Sidebar>
            <Outlet />
        </div>
    )
}

export default Root;

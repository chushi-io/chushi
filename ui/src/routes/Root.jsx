import * as React from "react";
import Sidebar from "../components/Sidebar";
import {Outlet} from "react-router-dom";
import {Container} from "@mui/material";

const Root = () => {
    return (
        <div style={{display: "flex", height: "100vh"}}>
            <Sidebar>

            </Sidebar>
            <Container>
                <Outlet />
            </Container>
        </div>
    )
}

export default Root;

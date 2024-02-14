import * as React from "react";
import {useEffect, useState} from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import axios from "axios";
import {Alert} from "@mui/material";
import {Link} from "react-router-dom";
import Button from "@mui/material/Button";

const ListVcsConnections = () => {
    const [vcsConnections, setVcsConnections] = useState([]);
    const orgs = useOrganizations();

    useEffect(() => {
        console.log(orgs.currentOrganizationr)
        if (orgs.currentOrganization === undefined) {
            return
        }
        axios.get(`/api/v1/orgs/${orgs.currentOrganization}/vcs_connections`)
            .then(res => setVcsConnections(res.data.vcs_connections))
    }, [orgs.currentOrganization])
    return (
        <React.Fragment>
            {vcsConnections.length === 0 && <Alert severity="info">No VCS connections have been configured yet!</Alert>}
            <ul>
                {vcsConnections.map(conn => {
                    return <li>{conn.name}</li>
                })}
            </ul>
            <Button variant="outlined">
                <Link to={"/vcs_connections/new"}>New VCS Connection</Link>
            </Button>
        </React.Fragment>
    )
}

export default ListVcsConnections;

import * as React from "react";
import {useEffect, useState} from "react";
import {useOrganizations} from "../providers/OrganizationProvider";
import axios from "axios";
import {Link} from "react-router-dom";
import {Alert, Anchor, Breadcrumbs, Button} from "@mantine/core";

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
          <Breadcrumbs>
            <Anchor component={Link} to={"/vcs_connections"}>VCS Connections</Anchor>
          </Breadcrumbs>
            {vcsConnections.length === 0 && <Alert variant="light" color={"yellow"}>No VCS connections have been configured yet!</Alert>}
            <ul>
                {vcsConnections.map(conn => {
                    return <li>{conn.name}</li>
                })}
            </ul>
            <Button component={Link} to={"/vcs_connections/new"} variant="outline">
                New VCS Connection
            </Button>
        </React.Fragment>
    )
}

export default ListVcsConnections;
